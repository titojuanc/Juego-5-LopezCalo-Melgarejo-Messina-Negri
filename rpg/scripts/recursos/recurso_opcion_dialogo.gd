extends Resource
class_name RecursoOpcionDialogo

@export var id: StringName = &""
@export var texto: String = ""
@export_multiline var respuesta: Array[String] = []
@export var miembro_party: RecursoPersonajeCombate
@export var flag_requerido: StringName = &""
@export var valor_flag_requerido: bool = true
@export var flag_al_seleccionar: StringName = &""
@export var valor_flag_al_seleccionar: bool = true
@export var perfil_requerido: RecursoPerfilAlineamiento
@export var distancia_maxima: float = 0.75
@export var accion_moral: RecursoAccionMoral
@export var inicia_combate: bool = false
@export var retira_npc: bool = false
@export_range(-100.0, 100.0, 1.0) var reputacion_minima: float = -100.0
