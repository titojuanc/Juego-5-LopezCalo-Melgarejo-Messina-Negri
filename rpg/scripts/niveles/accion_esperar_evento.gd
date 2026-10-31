extends "res://scripts/niveles/accion_evento.gd"
class_name AccionEsperarEvento

@export_range(0.0, 60.0, 0.1, "suffix:s") var duracion: float = 1.0


func ejecutar(_disparador: Node2D) -> void:
	if duracion > 0.0:
		await get_tree().create_timer(duracion).timeout
