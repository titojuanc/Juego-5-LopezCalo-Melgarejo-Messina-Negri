extends CanvasLayer

signal dialogo_iniciado
signal dialogo_finalizado

@export_range(1.0, 200.0) var caracteres_por_segundo: float = 35.0

var activo: bool = false
var escribiendo: bool = false
var _disponibles: Array[Node2D] = []
var _lineas: Array[String] = []
var _indice: int = 0
var _caracteres_visibles: float = 0.0

@onready var _caja: PanelContainer = $Pantalla/Caja
@onready var _nombre: Label = $Pantalla/Caja/Margen/Contenido/Nombre
@onready var _texto: RichTextLabel = $Pantalla/Caja/Margen/Contenido/Texto


func _ready() -> void:
	_caja.hide()


func registrar(interactuable: Node2D) -> void:
	if not _disponibles.has(interactuable):
		_disponibles.append(interactuable)


func desregistrar(interactuable: Node2D) -> void:
	_disponibles.erase(interactuable)


func iniciar(nombre: String, lineas: Array[String]) -> void:
	if activo:
		return
	_lineas.clear()
	for linea in lineas:
		if not linea.strip_edges().is_empty():
			_lineas.append(linea)
	if _lineas.is_empty():
		return
	activo = true
	_indice = 0
	_nombre.text = nombre
	_nombre.visible = not nombre.is_empty()
	_caja.show()
	_mostrar_linea()
	dialogo_iniciado.emit()


func _process(delta: float) -> void:
	if not activo or not escribiendo:
		return
	_caracteres_visibles += caracteres_por_segundo * delta
	_texto.visible_characters = mini(int(_caracteres_visibles), _texto.get_total_character_count())
	if _texto.visible_characters >= _texto.get_total_character_count():
		escribiendo = false


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo() or not evento.is_action_pressed("interactuar"):
		return
	if activo:
		get_viewport().set_input_as_handled()
		if escribiendo:
			_texto.visible_characters = -1
			escribiendo = false
		elif _indice + 1 < _lineas.size():
			_indice += 1
			_mostrar_linea()
		else:
			finalizar()
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
		iniciar(cercano.nombre, cercano.lineas)


func _mostrar_linea() -> void:
	_texto.text = _lineas[_indice]
	_texto.visible_characters = 0
	_texto.get_v_scroll_bar().value = 0
	_caracteres_visibles = 0.0
	escribiendo = true


func finalizar() -> void:
	if not activo:
		return
	activo = false
	escribiendo = false
	_caja.hide()
	_lineas.clear()
	dialogo_finalizado.emit()
