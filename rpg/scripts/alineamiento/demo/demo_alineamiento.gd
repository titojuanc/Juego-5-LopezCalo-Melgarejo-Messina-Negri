extends Node2D

const ESTADOS = ["Hostil", "Indiferente", "Amistoso"]
const COLORES = [Color(1.0, 0.45, 0.45), Color(0.85, 0.85, 0.85), Color(0.5, 1.0, 0.5)]

@export var buena_accion: RecursoAccionMoral

@export var mala_accion: RecursoAccionMoral

@onready var label_alineamiento: Label = $Hud/LabelAlineamiento
@onready var label_reputacion: Label = $Hud/LabelReputacion

var _etiquetas: Dictionary = {}

func _ready() -> void:
	Reputacion.reiniciar()
	for npc in find_children("*", "Npc", true, false):
		var etiqueta = Label.new()
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		etiqueta.position = Vector2(-150, -215)
		etiqueta.size = Vector2(300, 110)
		npc.add_child(etiqueta)
		_etiquetas[npc] = etiqueta
	queue_redraw()

func _draw() -> void:
	for npc in _etiquetas:
		var radio = npc.area_vision.get_child(0).shape.radius
		draw_arc(npc.position, radio, 0.0, TAU, 64, Color(1, 1, 1, 0.15), 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_Q:
			Alineamiento.aplicar_accion(buena_accion)
		KEY_E:
			Alineamiento.aplicar_accion(mala_accion)
		KEY_R:
			Reputacion.reiniciar()
		_:
			var indice = event.keycode - KEY_1
			if indice < 0 or indice > 8:
				return
			Alineamiento.establecer(1.0 - indice % 3, 1.0 - floori(indice / 3.0))

func _process(_delta: float) -> void:
	label_alineamiento.text = "Alineamiento: %s   (ley %.2f, bien %.2f)" % [Alineamiento.nombre_actual(), Alineamiento.ley, Alineamiento.bien]
	var zona = Reputacion.zona_actual()
	label_reputacion.text = "Reputación en %s: %d   (global: %d)" % [Reputacion.nombre_de(zona), roundi(Reputacion.reputacion_de(zona)), roundi(Reputacion.reputacion_global())]
	for npc in _etiquetas:
		var estado = npc.reputacion.estado
		_etiquetas[npc].text = _texto_npc(npc, estado)
		_etiquetas[npc].modulate = COLORES[estado]

func _texto_npc(npc: Npc, estado: int) -> String:
	var ataca = "no"
	if estado == CalculoAlineamiento.Estado.HOSTIL:
		ataca = "sí" if npc.conoce_al_jugador() else "no, todavía no te conoce"
	return "%s (%s)\n%s (afinidad %.1f)\nTe conoce: %d / %d\n¿Atacaría? %s" % [npc.nombre, npc.datos.perfil.nombre, ESTADOS[estado], npc.reputacion.afinidad, absi(roundi(Reputacion.reputacion_actual())), roundi(npc.datos.umbral_conocimiento), ataca]
