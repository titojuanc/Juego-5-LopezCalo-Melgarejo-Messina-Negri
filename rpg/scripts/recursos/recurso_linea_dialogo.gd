extends Resource
class_name RecursoLineaDialogo

# Si hay miembro, habla ese sidekick y la linea solo aparece cuando esta en la party.
@export var miembro: RecursoPersonajeCombate
@export var hablante: String = ""
@export_multiline var texto: String = ""


func nombre_hablante() -> String:
	if(miembro != null):
		return miembro.nombre
	return hablante


func retrato() -> Texture2D:
	return null if miembro == null else miembro.retrato


func disponible() -> bool:
	if texto.strip_edges().is_empty():
		return false
	return miembro ==null or Equipo.miembros.has(miembro)
