extends "res://scripts/niveles/accion_evento.gd"
class_name AccionConversacion

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

@export var lineas: Array[RecursoLineaDialogo] = []
@export var opciones: Array[OpcionDialogo] = []
# Personajes que estan en la escena sin ser de la party, como el sidekick que se esta reclutando.
@export var presentes: Array[RecursoPersonajeCombate] = []


func ejecutar(_disparador: Node2D) -> void:
	MotorDialogo.iniciar_conversacion(lineas, opciones, presentes)
	if MotorDialogo.activo:
		await MotorDialogo.dialogo_finalizado
