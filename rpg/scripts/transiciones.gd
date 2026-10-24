extends CanvasLayer

signal transicion_iniciada
signal transicion_finalizada

@export_range(0.05, 3.0) var duracion_fundido: float = 0.4

var en_curso: bool = false

@onready var _fundido: ColorRect = $Fade


func _ready() -> void:
	_fundido.hide()
	_fundido.modulate.a = 0.0


func _input(_evento: InputEvent) -> void:
	if en_curso:
		get_viewport().set_input_as_handled()


func cambiar_escena(ruta: String, puerta_destino: StringName = &"") -> void:
	if en_curso:
		return
	if ruta.is_empty() or not ResourceLoader.exists(ruta, "PackedScene"):
		push_warning("La puerta no tiene una escena destino valida: %s" % ruta)
		return
	en_curso = true
	MotorDialogo.finalizar()
	_fundido.show()
	transicion_iniciada.emit()
	await _animar_fundido(1.0)
	var error: Error = get_tree().change_scene_to_file(ruta)
	if error == OK:
		await get_tree().scene_changed
		if not puerta_destino.is_empty():
			await _ubicar_jugador(puerta_destino)
	else:
		push_error("No se pudo abrir la escena %s: %s" % [ruta, error_string(error)])
	await _animar_fundido(0.0)
	_fundido.hide()
	en_curso = false
	transicion_finalizada.emit()


func _ubicar_jugador(identificador: StringName) -> void:
	var escena: Node = get_tree().current_scene
	var puertas: Array[Node] = []
	for puerta in get_tree().get_nodes_in_group("Puertas"):
		if (puerta == escena or escena.is_ancestor_of(puerta)) and puerta.identificador == identificador:
			puertas.append(puerta)
	if puertas.size() != 1:
		push_warning("Se esperaba una puerta '%s' en %s; se encontraron %d" % [identificador, escena.scene_file_path, puertas.size()])
		return
	for jugador in get_tree().get_nodes_in_group("Jugador"):
		if jugador is CharacterBody2D and escena.is_ancestor_of(jugador):
			await puertas[0].colocar_jugador(jugador)
			return
	push_warning("La escena destino no tiene un CharacterBody2D del grupo Jugador")


func _animar_fundido(opacidad: float) -> void:
	var animacion: Tween = create_tween()
	animacion.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	animacion.tween_property(_fundido, "modulate:a", opacidad, duracion_fundido)
	await animacion.finished
