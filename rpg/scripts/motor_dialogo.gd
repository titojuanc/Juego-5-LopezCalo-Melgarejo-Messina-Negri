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
var _hablantes: Array[String] = []
var _retratos: Array[Texture2D] = []
var _opciones_dialogo: Array[OpcionDialogo] = []
var _botones_opciones: Array[Button] = []
var _indice: int = 0
var _indice_opcion: int = 0
var _caracteres_visibles: float = 0.0
var _nombre_dialogo: String = ""
var _retrato_dialogo: Texture2D
var _mostrando_opciones: bool = false
var _eleccion_realizada: bool = false

@onready var _caja: PanelContainer = $Pantalla/Caja
@onready var _nombre: Label = $Pantalla/Caja/Margen/Fila/Contenido/Nombre
@onready var _texto: RichTextLabel = $Pantalla/Caja/Margen/Fila/Contenido/Texto
@onready var _opciones: VBoxContainer = $Pantalla/Caja/Margen/Fila/Contenido/Opciones
@onready var _retrato: TextureRect = $Pantalla/Caja/Margen/Fila/Retrato


func _ready() -> void:
	_caja.hide()
	_opciones.hide()


func registrar(interactuable: Node2D) -> void:
	if not _disponibles.has(interactuable):
		_disponibles.append(interactuable)


func desregistrar(interactuable: Node2D) -> void:
	_disponibles.erase(interactuable)


func iniciar(nombre: String, lineas: Array[String], opciones: Array[OpcionDialogo] = [], retrato: Texture2D = null) -> void:
	var hablantes: Array[String] = []
	hablantes.resize(lineas.size())
	hablantes.fill(nombre)
	var retratos: Array[Texture2D] = []
	retratos.resize(lineas.size())
	retratos.fill(retrato)
	_iniciar(nombre, retrato, lineas, hablantes, retratos, opciones)


# Cada linea tiene su propio hablante; las de sidekicks fuera de la party se saltean.
func iniciar_conversacion(lineas: Array[RecursoLineaDialogo], opciones: Array[OpcionDialogo] = []) -> void:
	var textos: Array[String] = []
	var hablantes: Array[String] = []
	var retratos: Array[Texture2D] = []
	for linea in lineas:
		if linea ==null or not linea.disponible():
			continue
		textos.append(linea.texto)
		hablantes.append(linea.nombre_hablante())
		retratos.append(_retrato_de_linea(linea))
	var ultimo: String = "" if hablantes.is_empty() else hablantes[-1]
	var ultimo_retrato: Texture2D = null if retratos.is_empty() else retratos[-1]
	_iniciar(ultimo, ultimo_retrato, textos, hablantes, retratos, opciones)


func _iniciar(nombre: String, retrato: Texture2D, lineas: Array[String], hablantes: Array[String], retratos: Array[Texture2D], opciones: Array[OpcionDialogo]) -> void:
	if activo:
		return
	_cargar_lineas(lineas, hablantes, retratos)
	_opciones_dialogo.clear()
	for opcion in opciones:
		if not _opcion_visible(opcion):
			continue
		_opciones_dialogo.append(opcion)
	if not _opciones_dialogo.any(_opcion_disponible):
		_opciones_dialogo.clear()
	if _lineas.is_empty() and _opciones_dialogo.is_empty():
		return
	activo = true
	_indice = 0
	_nombre_dialogo = nombre
	_retrato_dialogo = retrato
	_eleccion_realizada = false
	_nombre.text = nombre
	_nombre.visible = not nombre.is_empty()
	_mostrar_retrato(retrato)
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
			var retrato: Texture2D = null
			if cercano.has_method("obtener_retrato_dialogo"):
				retrato = cercano.obtener_retrato_dialogo()
			iniciar(cercano.nombre, cercano.lineas, opciones, retrato)


func _mostrar_linea() -> void:
	_opciones.hide()
	_nombre.text = _hablantes[_indice]
	_nombre.visible = not _nombre.text.is_empty()
	_mostrar_retrato(_retratos[_indice])
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
		var opcion: OpcionDialogo = _opciones_dialogo[indice]
		boton.text = opcion.texto
		if opcion.perfil_requerido != null:
			boton.text = "[%s] %s" % [opcion.perfil_requerido.nombre, opcion.texto]
			boton.disabled = not _cumple_alineamiento(opcion)
		boton.custom_minimum_size = Vector2(0, 40)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.focus_mode = Control.FOCUS_ALL
		boton.pressed.connect(_seleccionar_opcion.bind(indice))
		boton.focus_entered.connect(_enfocar_opcion.bind(indice))
		_opciones.add_child(boton)
		_botones_opciones.append(boton)
	_opciones.show()
	_actualizar_altura_caja(_botones_opciones.size())
	for boton in _botones_opciones:
		if not boton.disabled:
			boton.grab_focus()
			return


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
	if(opcion.accion_moral != null):
		Alineamiento.aplicar_accion(opcion.accion_moral)
	opcion_elegida.emit(opcion)
	_mostrando_opciones = false
	_eleccion_realizada = true
	_esconder_botones()
	var lineas: Array[String] = [opcion.texto]
	lineas.append_array(opcion.respuesta)
	var hablantes: Array[String] = []
	hablantes.resize(lineas.size())
	hablantes.fill(_nombre_dialogo)
	hablantes[0] = nombre_protagonista
	var retratos: Array[Texture2D] = []
	retratos.resize(lineas.size())
	retratos.fill(_retrato_dialogo)
	retratos[0] = _obtener_retrato_protagonista()
	_cargar_lineas(lineas, hablantes, retratos)
	_indice = 0
	_mostrar_linea()


func _opcion_disponible(opcion: OpcionDialogo) -> bool:
	return _opcion_visible(opcion) and _cumple_alineamiento(opcion)


func _cumple_alineamiento(opcion: OpcionDialogo) -> bool:
	return opcion.perfil_requerido == null or Alineamiento.cerca_de(opcion.perfil_requerido, opcion.distancia_maxima)


func _opcion_visible(opcion: OpcionDialogo) -> bool:
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


func _cargar_lineas(lineas: Array[String], hablantes: Array[String], retratos: Array[Texture2D]) -> void:
	_lineas.clear()
	_hablantes.clear()
	_retratos.clear()
	for i in lineas.size():
		if lineas[i].strip_edges().is_empty():
			continue
		_lineas.append(lineas[i])
		_hablantes.append(hablantes[i])
		_retratos.append(retratos[i])


func _mostrar_retrato(retrato: Texture2D) -> void:
	_retrato.texture = retrato
	_retrato.visible = retrato != null


func _retrato_de_linea(linea: RecursoLineaDialogo) -> Texture2D:
	if(linea.miembro != null and linea.miembro == Equipo.lider()):
		return _obtener_retrato_protagonista()
	return linea.retrato()


# Usa el retrato cargado en el lider de la party y, si no tiene, el sprite del jugador.
func _obtener_retrato_protagonista() -> Texture2D:
	var lider: RecursoPersonajeCombate = Equipo.lider()
	if lider != null and lider.retrato !=null:
		return lider.retrato
	var jugador: Node2D = GestorJugador.jugador
	if not is_instance_valid(jugador):
		return null
	var sprite: AnimatedSprite2D = jugador.get_node_or_null("CharacterBody2D/AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return null
	var animacion: StringName = &"Idle" if sprite.sprite_frames.has_animation(&"Idle") else sprite.animation
	if not sprite.sprite_frames.has_animation(animacion) or sprite.sprite_frames.get_frame_count(animacion) == 0:
		return null
	return sprite.sprite_frames.get_frame_texture(animacion, 0)


func finalizar() -> void:
	if not activo:
		return
	_esconder_botones()
	activo = false
	escribiendo = false
	_caja.hide()
	_lineas.clear()
	_hablantes.clear()
	_retratos.clear()
	_opciones_dialogo.clear()
	_retrato_dialogo = null
	_mostrar_retrato(null)
	_eleccion_realizada = false
	dialogo_finalizado.emit()
