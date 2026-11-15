extends CanvasLayer
class_name GestorMapa

const SEPARACION := 96.0
const MARGEN := 24.0
const COLOR_SALA := Color(0.25, 0.3, 0.42)
const COLOR_ACTUAL := Color(0.9, 0.7, 0.2)
const COLOR_BORDE := Color(0.9, 0.9, 0.9)
const COLOR_CAMINO := Color(0.65, 0.65, 0.65)

@export var mapas: Array[RecursoMapa] = []

@onready var fondo: ColorRect = $Fondo
@onready var panel: PanelContainer = $Panel
@onready var titulo: Label = $Panel/Margen/Contenido/Titulo
@onready var lienzo: Control = $Panel/Margen/Contenido/Lienzo

var visitadas: Array = []
var conexiones: Array = []
var actual: String = ""
var _mapa_calculado: RecursoMapa
var _salas: Dictionary = {}
var _pasillos: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fondo.hide()
	panel.hide()
	lienzo.draw.connect(_dibujar)
	GestorJugador.jugador_acoplado.connect(_al_entrar_nivel)

func _al_entrar_nivel(_jugador: Node2D) -> void:
	var escena = get_tree().current_scene
	if escena == null:
		return
	var ruta = escena.scene_file_path
	if not actual.is_empty() and actual != ruta:
		var par = [actual, ruta]
		par.sort()
		if not conexiones.has(par):
			conexiones.append(par)
	if not visitadas.has(ruta):
		visitadas.append(ruta)
	actual = ruta
	var mapa = _mapa_actual()
	if mapa:
		_calcular_geometria(mapa)

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if panel.visible and (evento.is_action_pressed("mapa") or evento.is_action_pressed("cancelar") or evento.is_action_pressed("ui_cancel")):
		cerrar()
		get_viewport().set_input_as_handled()
	elif evento.is_action_pressed("mapa") and _se_puede_abrir():
		abrir()
		get_viewport().set_input_as_handled()

func _se_puede_abrir() -> bool:
	return GestorJugador.jugador.is_inside_tree() and not get_tree().paused and not MotorDialogo.activo and not Transiciones.en_curso and not GestorEventos.en_curso

func abrir() -> void:
	var mapa = _mapa_actual()
	titulo.text = mapa.nombre if mapa else "Mapa"
	fondo.show()
	panel.show()
	lienzo.queue_redraw()
	get_tree().paused = true

func cerrar() -> void:
	fondo.hide()
	panel.hide()
	get_tree().paused = false

func _mapa_actual() -> RecursoMapa:
	for mapa in mapas:
		if mapa.sala_de(actual):
			return mapa
	return null

func _dibujar() -> void:
	var fuente = ThemeDB.fallback_font
	var mapa = _mapa_actual()
	if mapa == null:
		lienzo.draw_string(fuente, Vector2(0, lienzo.size.y / 2), "No hay mapa de esta zona.", HORIZONTAL_ALIGNMENT_CENTER, lienzo.size.x)
		return
	_calcular_geometria(mapa)
	var salas = mapa.salas.filter(func(s): return visitadas.has(s.escena) and _salas.has(s.escena))
	var limites: Rect2 = _salas[salas[0].escena]
	for sala in salas:
		limites = limites.merge(_salas[sala.escena])
	var escala = minf((lienzo.size.x - MARGEN * 2) / limites.size.x, (lienzo.size.y - MARGEN * 2) / limites.size.y)
	var origen = (lienzo.size - limites.size * escala) / 2.0
	var a_lienzo = func(punto: Vector2): return origen + (punto - limites.position) * escala
	for par in conexiones:
		var clave = par[0] + "|" + par[1]
		if _pasillos.has(clave):
			lienzo.draw_line(a_lienzo.call(_pasillos[clave][0]), a_lienzo.call(_pasillos[clave][1]), COLOR_CAMINO, 6.0)
	for sala in salas:
		var mundo: Rect2 = _salas[sala.escena]
		var rect = Rect2(a_lienzo.call(mundo.position), mundo.size * escala)
		var es_actual = sala.escena == actual
		lienzo.draw_rect(rect, COLOR_ACTUAL if es_actual else COLOR_SALA)
		lienzo.draw_rect(rect, COLOR_BORDE, false, 2.0)
		var tamano_fuente = 16
		while tamano_fuente > 9 and fuente.get_string_size(sala.nombre, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_fuente).x > rect.size.x - 4:
			tamano_fuente -= 1
		lienzo.draw_string(fuente, Vector2(rect.position.x, rect.get_center().y + tamano_fuente * 0.35), sala.nombre, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, tamano_fuente, Color.BLACK if es_actual else Color.WHITE)

func _calcular_geometria(mapa: RecursoMapa) -> void:
	if _mapa_calculado == mapa:
		return
	_mapa_calculado = mapa
	_salas.clear()
	_pasillos.clear()
	var datos := {}
	for sala in mapa.salas:
		datos[sala.escena] = _leer_sala(sala.escena)
	var inicio = mapa.salas[0].escena
	_salas[inicio] = datos[inicio].rect
	var pendientes = [inicio]
	while not pendientes.is_empty():
		var a = pendientes.pop_front()
		var desplazamiento_a = _salas[a].position - datos[a].rect.position
		for puerta in datos[a].puertas:
			var b = puerta.destino
			if not datos.has(b) or _salas.has(b):
				continue
			var lado = _lado(datos[a].rect, puerta.posicion)
			var puerta_a = desplazamiento_a + puerta.posicion
			var rect_b: Rect2 = datos[b].rect
			var puerta_b = rect_b.get_center()
			for otra in datos[b].puertas:
				if otra.id == puerta.puerta_destino:
					puerta_b = otra.posicion
			var nuevo = Rect2(Vector2.ZERO, rect_b.size)
			if lado.y != 0:
				nuevo.position.x = puerta_a.x - (puerta_b.x - rect_b.position.x)
				nuevo.position.y = _salas[a].position.y - SEPARACION - rect_b.size.y if lado.y < 0 else _salas[a].end.y + SEPARACION
			else:
				nuevo.position.y = puerta_a.y - (puerta_b.y - rect_b.position.y)
				nuevo.position.x = _salas[a].position.x - SEPARACION - rect_b.size.x if lado.x < 0 else _salas[a].end.x + SEPARACION
			for intento in 50:
				if not _salas.values().any(func(r): return r.grow(-1).intersects(nuevo)):
					break
				nuevo.position += lado * SEPARACION
			_salas[b] = nuevo
			pendientes.append(b)
			var salida = puerta_a
			if lado.y != 0:
				salida.y = _salas[a].position.y if lado.y < 0 else _salas[a].end.y
			else:
				salida.x = _salas[a].position.x if lado.x < 0 else _salas[a].end.x
			var llegada: Vector2
			if lado.y < 0:
				llegada = Vector2(salida.x, nuevo.end.y)
			elif lado.y > 0:
				llegada = Vector2(salida.x, nuevo.position.y)
			elif lado.x < 0:
				llegada = Vector2(nuevo.end.x, salida.y)
			else:
				llegada = Vector2(nuevo.position.x, salida.y)
			var par = [a, b]
			par.sort()
			_pasillos[par[0] + "|" + par[1]] = [salida, llegada]
	for a in datos:
		if not _salas.has(a):
			continue
		for puerta in datos[a].puertas:
			var b = puerta.destino
			var par = [a, b]
			par.sort()
			if not _salas.has(b) or _pasillos.has(par[0] + "|" + par[1]):
				continue
			var puerta_b = null
			for otra in datos[b].puertas:
				if otra.id == puerta.puerta_destino:
					puerta_b = otra
			if puerta_b == null:
				continue
			_pasillos[par[0] + "|" + par[1]] = [_en_borde(datos[a], _salas[a], puerta.posicion), _en_borde(datos[b], _salas[b], puerta_b.posicion)]

func _leer_sala(ruta: String) -> Dictionary:
	var instancia = load(ruta).instantiate()
	var rect := Rect2()
	for capa in instancia.find_children("*", "TileMapLayer", true, false):
		var usado: Rect2i = capa.get_used_rect()
		if usado.size == Vector2i.ZERO:
			continue
		var tamano = Vector2(capa.tile_set.tile_size) * capa.scale
		var area = Rect2(capa.position + Vector2(usado.position) * tamano, Vector2(usado.size) * tamano)
		if capa.name == "Suelo":
			rect = area
			break
		rect = area if rect.size == Vector2.ZERO else rect.merge(area)
	var puertas = []
	for nodo in instancia.find_children("*", "", true, false):
		if not ("identificador" in nodo and "escena_destino" in nodo):
			continue
		var destino: String = nodo.escena_destino
		if destino.begins_with("uid://"):
			var id = ResourceUID.text_to_id(destino)
			destino = ResourceUID.get_id_path(id) if ResourceUID.has_id(id) else ""
		puertas.append({"id": nodo.identificador, "destino": destino, "puerta_destino": nodo.puerta_destino, "posicion": nodo.position})
	instancia.free()
	return {"rect": rect, "puertas": puertas}

func _en_borde(datos: Dictionary, sala: Rect2, posicion: Vector2) -> Vector2:
	var punto = sala.position + posicion - datos.rect.position
	var lado = _lado(datos.rect, posicion)
	if lado == Vector2.LEFT:
		punto.x = sala.position.x
	elif lado == Vector2.RIGHT:
		punto.x = sala.end.x
	elif lado == Vector2.UP:
		punto.y = sala.position.y
	else:
		punto.y = sala.end.y
	return punto

func _lado(rect: Rect2, punto: Vector2) -> Vector2:
	var distancias = {
		Vector2.LEFT: punto.x - rect.position.x,
		Vector2.RIGHT: rect.end.x - punto.x,
		Vector2.UP: punto.y - rect.position.y,
		Vector2.DOWN: rect.end.y - punto.y
	}
	var lado = Vector2.UP
	for direccion in distancias:
		if distancias[direccion] < distancias[lado]:
			lado = direccion
	return lado

func reiniciar() -> void:
	visitadas.clear()
	conexiones.clear()
	actual = ""

func a_diccionario() -> Dictionary:
	return {"visitadas": visitadas.duplicate(), "conexiones": conexiones.duplicate(true), "actual": actual}

func desde_diccionario(datos: Dictionary) -> void:
	visitadas = datos.get("visitadas", []).duplicate()
	conexiones = datos.get("conexiones", []).duplicate(true)
	actual = datos.get("actual", "")
