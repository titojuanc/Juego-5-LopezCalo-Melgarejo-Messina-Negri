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

@export_range(0.0, 100.0, 1.0) var umbral_conocimiento: float = 0.0

@export var sin_mente: bool = false

@export var reputacion_invertida: bool = false

@export var lineas_por_flag: Dictionary = {}

@export var velocidad_persecucion: float = 160.0
