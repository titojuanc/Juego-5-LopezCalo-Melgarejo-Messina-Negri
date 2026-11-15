extends Node
class_name QuitarSiFlag

# Al cargar la escena saca los nodos indicados si el flag ya tiene el valor esperado (ej: un sidekick ya reclutado).
@export var flag: StringName = &""
@export var valor: bool = true
@export var rutas: Array[NodePath] = []


func _ready() -> void:
	if flag.is_empty() or GestorEventos.obtener_flag(flag) != valor:
		return
	for ruta in rutas:
		var nodo: Node = get_node_or_null(ruta)
		if(nodo != null):
			nodo.queue_free()
