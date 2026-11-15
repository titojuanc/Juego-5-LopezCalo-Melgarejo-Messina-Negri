extends "res://scripts/niveles/accion_evento.gd"
class_name AccionDialogoEvento

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

@export var nombre: String = ""
@export_multiline var lineas: Array[String] = []
@export var opciones: Array[OpcionDialogo] = []


func ejecutar(_disparador: Node2D) -> void:
	MotorDialogo.iniciar(nombre, lineas, opciones)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado