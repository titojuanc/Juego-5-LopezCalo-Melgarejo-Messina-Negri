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