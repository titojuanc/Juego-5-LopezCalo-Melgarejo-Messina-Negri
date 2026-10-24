extends Node

var config := RecursoConfigAlineamiento.new()

var total := 0
var fallos := 0

func _ready() -> void:
	casos_documento()
	matriz_diagonal()
	matriz_legal_bueno()
	estados_y_ejes()
	casillas()
	presets()
	gestor()
	print("Alineamiento: %d/%d ok" % [total - fallos, total])
	get_tree().quit(fallos)

func perfil(ley, bien, umbrales := Vector2.ZERO, pesos := Vector2.ONE) -> RecursoPerfilAlineamiento:
	var p := RecursoPerfilAlineamiento.new()
	p.posicion_ley = ley
	p.posicion_bien = bien
	p.umbral_ley = umbrales.x
	p.umbral_bien = umbrales.y
	p.peso_ley = pesos.x
	p.peso_bien = pesos.y
	return p

func calc(p, ley, bien) -> Dictionary:
	return CalculoAlineamiento.calcular(p, ley, bien, config)

func check(nombre: String, obtenido, esperado) -> void:
	total += 1
	var ok = is_equal_approx(obtenido, esperado) if obtenido is float else obtenido == esperado
	if not ok:
		fallos += 1
		push_error("%s: esperaba %s, dio %s" % [nombre, esperado, obtenido])

func casos_documento() -> void:
	check("LB vs CM", calc(perfil(1, 1), -1, -1).afinidad, -2.0)
	check("LB vs N", calc(perfil(1, 1), 0, 0).afinidad, 0.0)
	check("LB umbral 1 vs N", calc(perfil(1, 1, Vector2(1, 1)), 0, 0).afinidad, 2.0)
	check("LB umbral 1 vs CM", calc(perfil(1, 1, Vector2(1, 1)), -1, -1).afinidad, 0.0)
	check("NM vs CM", calc(perfil(0, -1), -1, -1).afinidad, 1.0)
	check("N vs LB", calc(perfil(0, 0), 1, 1).afinidad, 0.0)
	check("LB peso ley 0 vs CB", calc(perfil(1, 1, Vector2.ZERO, Vector2(0, 1)), -1, 1).afinidad, 2.0)
	check("LB pesos 1.5 vs CM", calc(perfil(1, 1, Vector2.ZERO, Vector2(1.5, 1.5)), -1, -1).afinidad, -2.0)

func matriz_diagonal() -> void:
	var diagonal = [Vector2(1, 1), Vector2(0, 0), Vector2(-1, -1)]
	var esperados = [[2.0, 0.0, -2.0], [0.0, 2.0, 0.0], [-2.0, 0.0, 2.0]]
	for i in 3:
		for j in 3:
			var npc = diagonal[i]
			var jugador = diagonal[j]
			check("diagonal %s vs %s" % [npc, jugador], calc(perfil(npc.x, npc.y), jugador.x, jugador.y).afinidad, esperados[i][j])

func matriz_legal_bueno() -> void:
	var lb = perfil(1, 1)
	var casos = {Vector2(1, 1): 2.0, Vector2(0, 1): 1.0, Vector2(1, 0): 1.0, Vector2(-1, 1): 0.0, Vector2(0, 0): 0.0, Vector2(1, -1): 0.0, Vector2(-1, 0): -1.0, Vector2(0, -1): -1.0, Vector2(-1, -1): -2.0}
	for jugador in casos:
		check("LB vs %s" % jugador, calc(lb, jugador.x, jugador.y).afinidad, casos[jugador])

func estados_y_ejes() -> void:
	check("estado 1", CalculoAlineamiento.estado_de(1.0, config), CalculoAlineamiento.Estado.AMISTOSO)
	check("estado 0.99", CalculoAlineamiento.estado_de(0.99, config), CalculoAlineamiento.Estado.INDIFERENTE)
	check("estado -0.99", CalculoAlineamiento.estado_de(-0.99, config), CalculoAlineamiento.Estado.INDIFERENTE)
	check("estado -1", CalculoAlineamiento.estado_de(-1.0, config), CalculoAlineamiento.Estado.HOSTIL)
	check("estado LB vs CM", calc(perfil(1, 1), -1, -1).estado, CalculoAlineamiento.Estado.HOSTIL)
	check("eje LB vs LB", calc(perfil(1, 1), 1, 1).eje, CalculoAlineamiento.Eje.NINGUNO)
	check("eje LB vs N", calc(perfil(1, 1), 0, 0).eje, CalculoAlineamiento.Eje.AMBOS)
	check("eje LB vs CB", calc(perfil(1, 1), -1, 1).eje, CalculoAlineamiento.Eje.LEY)
	check("eje clerigo vs CM", calc(perfil(1, 1, Vector2(1, 0), Vector2(0.5, 1)), -1, -1).eje, CalculoAlineamiento.Eje.BIEN)

func casillas() -> void:
	check("casilla 0.34", CalculoAlineamiento.casilla(0.34, config), 1)
	check("casilla 0.33", CalculoAlineamiento.casilla(0.33, config), 0)
	check("casilla -0.34", CalculoAlineamiento.casilla(-0.34, config), -1)
	check("nombre LB", CalculoAlineamiento.nombre_alineamiento(1, 1, config), "Legal bueno")
	check("nombre N", CalculoAlineamiento.nombre_alineamiento(0.2, -0.2, config), "Neutral")
	check("nombre CM", CalculoAlineamiento.nombre_alineamiento(-1, -1, config), "Caótico malvado")
	check("nombre NB", CalculoAlineamiento.nombre_alineamiento(0, 1, config), "Neutral bueno")

func presets() -> void:
	var presets = {"legal_bueno": Vector2(1, 1), "neutral": Vector2(0, 0), "caotico_malvado": Vector2(-1, -1)}
	for nombre in presets:
		var p: RecursoPerfilAlineamiento = load("res://scenes/alineamiento/perfiles/%s.tres" % nombre)
		check("preset " + nombre, Vector2(p.posicion_ley, p.posicion_bien), presets[nombre])
		check("preset %s vs si mismo" % nombre, calc(p, p.posicion_ley, p.posicion_bien).afinidad, p.afinidad_base)

func gestor() -> void:
	var g := GestorAlineamiento.new()
	var emisiones = []
	g.alineamiento_cambiado.connect(func(ley, bien): emisiones.append(Vector2(ley, bien)))
	g.desplazar(-0.5, -0.5)
	g.desplazar(-1.0, -1.0)
	g.desplazar(-1.0, -1.0)
	check("gestor limita", Vector2(g.ley, g.bien), Vector2(-1, -1))
	check("gestor emite solo si cambia", emisiones.size(), 2)
	check("gestor nombre", g.nombre_actual(), "Caótico malvado")
	g.aplicar_accion(load("res://scenes/alineamiento/acciones/buena_accion.tres"))
	check("gestor aplica accion", Vector2(g.ley, g.bien), Vector2(-0.75, -0.75))
	g.desde_diccionario({"ley": 0.5, "bien": 0.25})
	check("gestor carga partida", g.a_diccionario(), {"ley": 0.5, "bien": 0.25})
	g.free()
