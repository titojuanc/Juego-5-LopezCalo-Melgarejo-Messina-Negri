extends "res://scripts/niveles/accion_evento.gd"
class_name AccionDialogoEvento

@export var nombre: String = ""
@export_multiline var lineas: Array[String] = []


func ejecutar(_disparador: Node2D) -> void:
	MotorDialogo.iniciar(nombre, lineas)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado