extends Camera3D
class_name CamaraCombate

@export var toma_overview: Marker3D
@export var toma_enemigo: Marker3D

@export var tomas_aliados: Array[Marker3D] = []

@export var duracion_transicion: float = 0.8
@export var tipo_transicion: Tween.TransitionType = Tween.TRANS_SINE
@export var tipo_facilitador: Tween.EaseType = Tween.EASE_IN_OUT

@export var fov_aliados: float = 60.0
@export var fov_enemigo: float = 80.0
@export var fov_overview: float = 70.0

var _tween: Tween

func enfocar_aliado(indice: int) -> void:
	if indice < 0 or indice >= tomas_aliados.size():
		return
	_mover_a(tomas_aliados[indice], fov_aliados)

func enfocar_enemigo() -> void:
	_mover_a(toma_enemigo, fov_enemigo)

func enfocar_overview() -> void:
	_mover_a(toma_overview, fov_overview)

func _mover_a(toma: Marker3D, fov_destino: float) -> void:
	if toma == null:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(tipo_transicion).set_ease(tipo_facilitador)
	_tween.set_parallel(true)
	_tween.tween_property(self, "global_transform", toma.global_transform, duracion_transicion)
	_tween.tween_property(self, "fov", fov_destino, duracion_transicion)
	
