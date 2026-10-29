extends Node

signal jugador_acoplado(jugador: Node2D)

const ESCENA_JUGADOR: PackedScene = preload("res://scenes/main_character.tscn")
const RUTA_NIVELES := "res://scenes/niveles/"
const GRUPO_INICIO := &"PuntoInicio"

var jugador: Node2D
var cuerpo: CharacterBody2D


func _ready() -> void:
	jugador = ESCENA_JUGADOR.instantiate()
	cuerpo = jugador.get_node("CharacterBody2D")
	get_tree().scene_changed.connect(sincronizar)
	sincronizar.call_deferred()


func _exit_tree() -> void:
	if is_instance_valid(jugador) and not jugador.is_inside_tree():
		jugador.free()


# Coloca al jugador en la escena actual si es un nivel; si no lo es, lo deja fuera del arbol.
func sincronizar() -> void:
	var escena: Node = get_tree().current_scene
	if escena == null:
		return
	if not escena.scene_file_path.begins_with(RUTA_NIVELES):
		desacoplar()
		return
	if jugador.get_parent() == escena:
		return
	var inicio: Variant = _tomar_posicion_inicial(escena)
	desacoplar()
	escena.add_child(jugador)
	if inicio != null:
		cuerpo.global_position = inicio
		cuerpo.velocity = Vector2.ZERO
		cuerpo.reset_physics_interpolation()
	jugador_acoplado.emit(jugador)


# Hay que llamarlo antes de cambiar de escena, o el jugador se libera junto con la anterior.
func desacoplar() -> void:
	var padre: Node = jugador.get_parent()
	if padre != null:
		padre.remove_child(jugador)


# Un MainCharacter instanciado a mano en el nivel marca el inicio y se descarta en favor del persistente.
func _tomar_posicion_inicial(escena: Node) -> Variant:
	for nodo in get_tree().get_nodes_in_group("Jugador"):
		if nodo != cuerpo and escena.is_ancestor_of(nodo):
			var posicion: Vector2 = nodo.global_position
			var incrustado: Node = nodo.get_parent()
			incrustado.get_parent().remove_child(incrustado)
			incrustado.queue_free()
			return posicion
	for marcador in get_tree().get_nodes_in_group(GRUPO_INICIO):
		if escena.is_ancestor_of(marcador):
			return marcador.global_position
	if not Transiciones.en_curso:
		push_warning("El nivel %s no tiene MainCharacter ni un nodo del grupo '%s'" % [escena.scene_file_path, GRUPO_INICIO])
	return null
