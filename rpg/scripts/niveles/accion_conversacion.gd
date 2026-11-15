extends "res://scripts/niveles/accion_evento.gd"
class_name AccionConversacion

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

@export var lineas: Array[RecursoLineaDialogo] = []
@export var opciones: Array[OpcionDialogo] = []


func ejecutar(_disparador: Node2D) -> void:
	MotorDialogo.iniciar_conversacion(lineas, opciones)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado
