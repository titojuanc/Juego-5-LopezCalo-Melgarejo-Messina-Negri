extends Node
class_name GestorRumores

signal rumores_cambiados

enum Alcance {TESTIGOS, NIVEL, ZONA, TODOS}

var rumores: Array = []

func _ready() -> void:
	Alineamiento.accion_aplicada.connect(_on_accion_aplicada)
	Transiciones.transicion_finalizada.connect(propagar)

func _on_accion_aplicada(accion: RecursoAccionMoral) -> void:
	registrar(accion.notoriedad)

func registrar(notoriedad: float) -> void:
	var nivel = _nivel_actual()
	var testigos: Array = []
	for npc in get_tree().get_nodes_in_group("npcs"):
		if npc.ve_al_jugador() and npc.datos and not npc.datos.id.is_empty():
			testigos.append(npc.datos.id)
	rumores.append({
		"notoriedad": notoriedad,
		"nivel": nivel,
		"zona": nivel.get_base_dir(),
		"alcance": Alcance.TESTIGOS,
		"testigos": testigos
	})
	rumores_cambiados.emit()

func propagar() -> void:
	if rumores.is_empty():
		return
	for rumor in rumores:
		rumor.alcance = mini(rumor.alcance + 1, Alcance.TODOS)
	rumores_cambiados.emit()

func conocimiento_de(id: StringName, nivel: String) -> float:
	var total := 0.0
	for rumor in rumores:
		if _llega(rumor, id, nivel):
			total += rumor.notoriedad
	return total

func _llega(rumor: Dictionary, id: StringName, nivel: String) -> bool:
	if rumor.testigos.has(id):
		return true
	match rumor.alcance:
		Alcance.TODOS:
			return true
		Alcance.ZONA:
			return nivel.get_base_dir() == rumor.zona
		Alcance.NIVEL:
			return nivel == rumor.nivel
	return false

func _nivel_actual() -> String:
	var escena = get_tree().current_scene
	if escena == null:
		return ""
	return escena.scene_file_path

func reiniciar() -> void:
	rumores.clear()
	rumores_cambiados.emit()

func a_diccionario() -> Dictionary:
	return {"rumores": rumores.duplicate(true)}

func desde_diccionario(datos: Dictionary) -> void:
	rumores = datos.get("rumores", []).duplicate(true)
	rumores_cambiados.emit()
