extends Resource
class_name RecursoNpc

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

@export var id: StringName

@export var nombre: String

@export var sprite_frames: SpriteFrames

@export var perfil: RecursoPerfilAlineamiento

@export_multiline var lineas_amistoso: Array[String] = []

@export_multiline var lineas_indiferente: Array[String] = []

@export_multiline var lineas_hostil: Array[String] = []

@export var opciones_amistoso: Array[OpcionDialogo] = []

@export var opciones_indiferente: Array[OpcionDialogo] = []

@export var opciones_hostil: Array[OpcionDialogo] = []

@export var motivo_legal: String

@export var motivo_caotico: String

@export var motivo_bueno: String

@export var motivo_malvado: String

@export var enemigos: Array[RecursoEnemigo] = []
