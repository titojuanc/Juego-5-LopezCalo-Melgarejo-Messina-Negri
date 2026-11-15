extends "res://scripts/niveles/accion_evento.gd"
class_name AccionQuitarNodo

# Sirve para sacar de escena al sidekick una vez que se une a la party.
@export var ruta_nodo: NodePath


func ejecutar(_disparador: Node2D) -> void:
	var nodo: Node = get_node_or_null(ruta_nodo)
	if(nodo == null):
		push_warning("La accion para quitar un nodo no encontro %s" % ruta_nodo)
		return
	nodo.queue_free()
