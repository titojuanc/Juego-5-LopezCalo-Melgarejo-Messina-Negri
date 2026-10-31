extends Node2D
class_name DisparadorEvento

enum ModoActivacion { INTERACTUAR, ENTRAR_EN_ZONA }

@export var modo: ModoActivacion = ModoActivacion.INTERACTUAR
@export var identificador: StringName = &""
@export var solo_una_vez: bool = true
@export var flag_requerido: StringName = &""
@export var valor_flag_requerido: bool = true

var _areas_jugador: Array[Area2D] = []
var _en_curso: bool = false

@onready var _area: Area2D = $Area2D
@onready var _acciones: Node = $Acciones
@onready var _indicador: Sprite2D = $IndicadorInteraccion


func _ready() -> void:
	_area.area_entered.connect(_al_entrar_area)
	_area.area_exited.connect(_al_salir_area)
	_area.body_entered.connect(_al_entrar_cuerpo)


func _process(_delta: float) -> void:
	_indicador.visible = modo == ModoActivacion.INTERACTUAR and not _areas_jugador.is_empty() and puede_activarse()


func _al_entrar_area(area: Area2D) -> void:
	if modo != ModoActivacion.INTERACTUAR or not area.is_in_group("InteraccionJugador"):
		return
	if not _areas_jugador.has(area):
		_areas_jugador.append(area)
		MotorDialogo.registrar(self)


func _al_salir_area(area: Area2D) -> void:
	_areas_jugador.erase(area)
	if _areas_jugador.is_empty():
		MotorDialogo.desregistrar(self)


func _al_entrar_cuerpo(cuerpo: Node2D) -> void:
	if modo == ModoActivacion.ENTRAR_EN_ZONA and cuerpo.is_in_group("Jugador"):
		ejecutar_evento()


func ejecutar_evento() -> void:
	GestorEventos.ejecutar_evento(self)


func tiene_dialogo() -> bool:
	return modo == ModoActivacion.INTERACTUAR and not _acciones.get_children().is_empty() and puede_activarse()


func distancia_al_jugador() -> float:
	var distancia: float = INF
	for area in _areas_jugador:
		if is_instance_valid(area):
			distancia = minf(distancia, global_position.distance_squared_to(area.global_position))
	return distancia


func puede_activarse() -> bool:
	if _en_curso or GestorEventos.en_curso:
		return false
	if solo_una_vez and GestorEventos.evento_completado(clave_evento()):
		return false
	if not flag_requerido.is_empty() and GestorEventos.obtener_flag(flag_requerido) != valor_flag_requerido:
		return false
	return true


func clave_evento() -> StringName:
	if not identificador.is_empty():
		return identificador
	var escena: Node = get_tree().current_scene
	var ruta_escena: String = escena.scene_file_path if escena != null else ""
	return StringName("%s::%s" % [ruta_escena, get_path()])


func establecer_en_curso(valor: bool) -> void:
	_en_curso = valor


func _exit_tree() -> void:
	if is_instance_valid(MotorDialogo):
		MotorDialogo.desregistrar(self)
