extends Node
class_name GestorEncuentros

const ESCENA_MENU := "res://scenes/main_menu.tscn"
const AUMENTO_POR_PISO := 0.25

var enemigos: Array[RecursoEnemigo] = []

var npcs_derrotados: Array = []

var _npc: StringName = &""
var _gano := false
var _tregua: StringName = &""
var _escena_retorno: String = ""
var _posicion_retorno: Vector2

func iniciar(nuevos: Array[RecursoEnemigo], npc: StringName, escena_combate: String, nombre: String = "", textura: Texture2D = null) -> void:
	enemigos.clear()
	for enemigo in nuevos:
		if enemigo != null:
			enemigos.append(enemigo)
	if enemigos.is_empty():
		return
	if not nombre.is_empty():
		var propio: RecursoEnemigo = enemigos[0].duplicate()
		propio.nombre = nombre
		if textura:
			propio.textura = textura
		enemigos[0] = propio
	_npc = npc
	_gano = false
	var escena = get_tree().current_scene
	_escena_retorno = escena.scene_file_path if escena else ""
	if GestorJugador.cuerpo.is_inside_tree():
		_posicion_retorno = GestorJugador.cuerpo.global_position
	Transiciones.cambiar_escena(escena_combate)

func piso() -> int:
	var zona := _escena_retorno.get_base_dir().get_file()
	return maxi(zona.trim_prefix("zona_").to_int() - 1, 0)

func multiplicador_piso() -> float:
	return 1.0 + AUMENTO_POR_PISO * piso()

func derrotado(npc: StringName) -> bool:
	return npcs_derrotados.has(npc)

func tomar_tregua(npc: StringName) -> bool:
	if npc.is_empty() or _tregua != npc:
		return false
	_tregua = &""
	return true

func cobrar(datos_enemigos: Array, miembros_vivos: Array) -> Dictionary:
	_gano = true
	var recompensa = {"exp": 0, "oro": 0, "items": [], "armas": [], "subidas": []}
	for enemigo in datos_enemigos:
		var factor := 1.0 if enemigo.es_jefe else multiplicador_piso()
		recompensa.exp += roundi(enemigo.experiencia * factor)
		recompensa.oro += roundi(enemigo.oro * factor)
		if enemigo.item_drop and randf() < enemigo.probabilidad_drop:
			recompensa.items.append(enemigo.item_drop)
		if enemigo.arma_drop:
			recompensa.armas.append(enemigo.arma_drop)
	for miembro in miembros_vivos:
		var antes = Equipo.nivel_de(miembro)
		Equipo.dar_experiencia(miembro, recompensa.exp)
		if Equipo.nivel_de(miembro) > antes:
			recompensa.subidas.append({"nombre": miembro.nombre, "nivel": Equipo.nivel_de(miembro)})
	Equipo.agregar_oro(recompensa.oro)
	for item in recompensa.items:
		Equipo.agregar_item(item)
	for arma in recompensa.armas:
		Equipo.equipar_si_mejor(Equipo.lider(), arma)
	if not _npc.is_empty() and not npcs_derrotados.has(_npc):
		npcs_derrotados.append(_npc)
	return recompensa

func perder(jefe: bool) -> bool:
	_gano = false
	if jefe:
		for miembro in Equipo.miembros:
			Equipo.fijar_vida(miembro, 0)
		return true
	return Equipo.aplicar_derrota()

func volver() -> void:
	var ruta = _escena_retorno
	_tregua = &"" if _gano else _npc
	_limpiar()
	if ruta.is_empty():
		Transiciones.cambiar_escena(ESCENA_MENU)
		return
	GestorJugador.jugador_acoplado.connect(_colocar_jugador, CONNECT_ONE_SHOT)
	Transiciones.cambiar_escena(ruta)

func ir_al_menu() -> void:
	_limpiar()
	Transiciones.cambiar_escena(ESCENA_MENU)

func _colocar_jugador(_jugador: Node2D) -> void:
	GestorJugador.cuerpo.global_position = _posicion_retorno
	GestorJugador.cuerpo.velocity = Vector2.ZERO
	GestorJugador.cuerpo.reset_physics_interpolation()

func _limpiar() -> void:
	enemigos.clear()
	_npc = &""
	_escena_retorno = ""

func reiniciar() -> void:
	_limpiar()
	_tregua = &""
	npcs_derrotados.clear()

func a_diccionario() -> Dictionary:
	return {"npcs_derrotados": npcs_derrotados.duplicate()}

func desde_diccionario(datos: Dictionary) -> void:
	npcs_derrotados = datos.get("npcs_derrotados", []).duplicate()
