extends CanvasLayer

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

signal dialogo_iniciado
signal dialogo_finalizado
signal opcion_elegida(opcion: OpcionDialogo)

@export_range(1.0, 200.0) var caracteres_por_segundo: float = 35.0
@export var nombre_protagonista: String = "Protagonista"

const ALTURA_BASE_CAJA: float = 188.0
const ALTURA_POR_OPCION: float = 44.0

var activo: bool = false
var escribiendo: bool = false
var _disponibles: Array[Node2D] = []
var _lineas: Array[String] = []
var _opciones_dialogo: Array[OpcionDialogo] = []
var _botones_opciones: Array[Button] = []
var _indice: int = 0
var _indice_opcion: int = 0
var _caracteres_visibles: float = 0.0
var _nombre_dialogo: String = ""
var _mostrando_opciones: bool = false
var _eleccion_realizada: bool = false
var _mostrando_respuesta_jugador: bool = false

@onready var _caja: PanelContainer = $Pantalla/Caja
@onready var _nombre: Label = $Pantalla/Caja/Margen/Contenido/Nombre
@onready var _texto: RichTextLabel = $Pantalla/Caja/Margen/Contenido/Texto
@onready var _opciones: VBoxContainer = $Pantalla/Caja/Margen/Contenido/Opciones


func _ready() -> void:
	_caja.hide()
	_opciones.hide()


func registrar(interactuable: Node2D) -> void:
	if not _disponibles.has(interactuable):
		_disponibles.append(interactuable)


func desregistrar(interactuable: Node2D) -> void:
	_disponibles.erase(interactuable)


func iniciar(nombre: String, lineas: Array[String], opciones: Array[OpcionDialogo] = []) -> void:
	if activo:
		return
	_lineas = _filtrar_lineas(lineas)
	_opciones_dialogo.clear()
	for opcion in opciones:
		if not _opcion_disponible(opcion):
			continue
		_opciones_dialogo.append(opcion)
	if _lineas.is_empty() and _opciones_dialogo.is_empty():
		return
	activo = true
	_indice = 0
	_nombre_dialogo = nombre
	_eleccion_realizada = false
	_mostrando_respuesta_jugador = false
	_nombre.text = nombre
	_nombre.visible = not nombre.is_empty()
	_caja.show()
	if _lineas.is_empty():
		_mostrar_opciones()
	else:
		_mostrar_linea()
	dialogo_iniciado.emit()


func _process(delta: float) -> void:
	if not activo or not escribiendo:
		return
	_caracteres_visibles += caracteres_por_segundo * delta
	_texto.visible_characters = mini(int(_caracteres_visibles), _texto.get_total_character_count())
	if _texto.visible_characters >= _texto.get_total_character_count():
		escribiendo = false
		if _indice + 1 >= _lineas.size() and not _opciones_dialogo.is_empty() and not _eleccion_realizada:
			_mostrar_opciones()


func _unhandled_input(evento: InputEvent) -> void:
	if activo:
		if _mostrando_opciones:
			if evento.is_echo():
				return
			if evento.is_action_pressed("ui_down"):
				_mover_opcion(1)
				get_viewport().set_input_as_handled()
			elif evento.is_action_pressed("ui_up"):
				_mover_opcion(-1)
				get_viewport().set_input_as_handled()
			elif evento.is_action_pressed("interactuar") or evento.is_action_pressed("ui_accept"):
				_seleccionar_opcion(_indice_opcion)
				get_viewport().set_input_as_handled()
			return
		if evento.is_echo() or not evento.is_action_pressed("interactuar"):
			return
		get_viewport().set_input_as_handled()
		if escribiendo:
			_texto.visible_characters = -1
			escribiendo = false
			if _indice + 1 >= _lineas.size() and not _opciones_dialogo.is_empty() and not _eleccion_realizada:
				_mostrar_opciones()
		elif _indice + 1 < _lineas.size():
			_indice += 1
			if _mostrando_respuesta_jugador:
				_nombre.text = _nombre_dialogo
				_nombre.visible = not _nombre_dialogo.is_empty()
				_mostrando_respuesta_jugador = false
			_mostrar_linea()
		elif not _opciones_dialogo.is_empty() and not _eleccion_realizada:
			_mostrar_opciones()
		else:
			finalizar()
		return
	if evento.is_echo() or not evento.is_action_pressed("interactuar"):
		return
	var cercano: Node2D = null
	var distancia_minima: float = INF
	for candidato in _disponibles.duplicate():
		if not is_instance_valid(candidato) or candidato.is_queued_for_deletion():
			_disponibles.erase(candidato)
			continue
		var distancia: float = candidato.distancia_al_jugador()
		if candidato.tiene_dialogo() and distancia < distancia_minima:
			cercano = candidato
			distancia_minima = distancia
	if cercano != null:
		get_viewport().set_input_as_handled()
		if cercano.has_method("ejecutar_evento"):
			cercano.ejecutar_evento()
		else:
			var opciones: Array[OpcionDialogo] = []
			if cercano.has_method("obtener_opciones_dialogo"):
				opciones = cercano.obtener_opciones_dialogo()
			iniciar(cercano.nombre, cercano.lineas, opciones)


func _mostrar_linea() -> void:
	_opciones.hide()
	_texto.text = _lineas[_indice]
	_texto.visible_characters = 0
	_texto.get_v_scroll_bar().value = 0
	_caracteres_visibles = 0.0
	escribiendo = true


func _mostrar_opciones() -> void:
	_esconder_botones()
	_mostrando_opciones = true
	_indice_opcion = 0
	for indice in _opciones_dialogo.size():
		var boton := Button.new()
		boton.text = _opciones_dialogo[indice].texto
		boton.custom_minimum_size = Vector2(0, 40)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.focus_mode = Control.FOCUS_ALL
		boton.pressed.connect(_seleccionar_opcion.bind(indice))
		boton.focus_entered.connect(_enfocar_opcion.bind(indice))
		_opciones.add_child(boton)
		_botones_opciones.append(boton)
	_opciones.show()
	_actualizar_altura_caja(_botones_opciones.size())
	if not _botones_opciones.is_empty():
		_botones_opciones[0].grab_focus()


func _mover_opcion(direccion: int) -> void:
	if _botones_opciones.is_empty():
		return
	_indice_opcion = posmod(_indice_opcion + direccion, _botones_opciones.size())
	_botones_opciones[_indice_opcion].grab_focus()


func _enfocar_opcion(indice: int) -> void:
	_indice_opcion = indice


func _seleccionar_opcion(indice: int) -> void:
	if not _mostrando_opciones or indice < 0 or indice >= _opciones_dialogo.size():
		return
	var opcion: OpcionDialogo = _opciones_dialogo[indice]
	if not _opcion_disponible(opcion):
		return
	if opcion.miembro_party != null and not Equipo.agregar(opcion.miembro_party):
		return
	if not opcion.flag_al_seleccionar.is_empty():
		GestorEventos.cambiar_flag(opcion.flag_al_seleccionar, opcion.valor_flag_al_seleccionar)
	opcion_elegida.emit(opcion)
	_mostrando_opciones = false
	_eleccion_realizada = true
	_esconder_botones()
	_lineas = _filtrar_lineas(opcion.respuesta)
	_lineas.push_front(opcion.texto)
	_indice = 0
	_mostrando_respuesta_jugador = true
	_nombre.text = nombre_protagonista
	_nombre.visible = not nombre_protagonista.is_empty()
	_mostrar_linea()


func _opcion_disponible(opcion: OpcionDialogo) -> bool:
	if opcion == null or opcion.texto.strip_edges().is_empty():
		return false
	if not opcion.flag_requerido.is_empty() and GestorEventos.obtener_flag(opcion.flag_requerido) != opcion.valor_flag_requerido:
		return false
	if opcion.miembro_party != null:
		if Equipo.miembros.has(opcion.miembro_party) or Equipo.miembros.size() >= Equipo.maximo:
			return false
	return true


func _esconder_botones() -> void:
	for boton in _botones_opciones:
		if is_instance_valid(boton):
			_opciones.remove_child(boton)
			boton.queue_free()
	_botones_opciones.clear()
	_mostrando_opciones = false
	_opciones.hide()
	_actualizar_altura_caja(0)


func _actualizar_altura_caja(cantidad_opciones: int) -> void:
	var altura_deseada: float = ALTURA_BASE_CAJA + cantidad_opciones * ALTURA_POR_OPCION
	var altura_maxima: float = maxf(ALTURA_BASE_CAJA, get_viewport().get_visible_rect().size.y * 0.65)
	_caja.offset_top = _caja.offset_bottom - minf(altura_deseada, altura_maxima)


func _filtrar_lineas(lineas: Array[String]) -> Array[String]:
	var resultado: Array[String] = []
	for linea in lineas:
		if not linea.strip_edges().is_empty():
			resultado.append(linea)
	return resultado


func finalizar() -> void:
	if not activo:
		return
	_esconder_botones()
	activo = false
	escribiendo = false
	_caja.hide()
	_lineas.clear()
	_opciones_dialogo.clear()
	_eleccion_realizada = false
	_mostrando_respuesta_jugador = false
	dialogo_finalizado.emit()
