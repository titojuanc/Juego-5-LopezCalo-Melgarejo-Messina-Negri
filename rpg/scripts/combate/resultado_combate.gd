extends CanvasLayer

@onready var titulo: Label = $Panel/Margen/Contenido/Titulo
@onready var detalle: Label = $Panel/Margen/Contenido/Detalle
@onready var boton_continuar: Button = $Panel/Margen/Contenido/Botones/Continuar
@onready var boton_menu: Button = $Panel/Margen/Contenido/Botones/Menu

func _ready() -> void:
	boton_continuar.pressed.connect(Encuentros.volver)
	boton_menu.pressed.connect(Encuentros.ir_al_menu)

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo() or not evento.is_action_pressed("interactuar"):
		return
	var foco = get_viewport().gui_get_focus_owner()
	if foco is Button and is_ancestor_of(foco):
		foco.pressed.emit()
		get_viewport().set_input_as_handled()

func mostrar_victoria(recompensa: Dictionary) -> void:
	titulo.text = "¡Victoria!"
	var lineas = ["EXP +%d" % recompensa.exp, "Oro +%d" % recompensa.oro]
	for item in recompensa.items:
		lineas.append("Obtuviste: " + item.nombre)
	for arma in recompensa.armas:
		lineas.append("Arma nueva: " + arma.nombre)
	for subida in recompensa.subidas:
		lineas.append("%s subió a nivel %d" % [subida.nombre, subida.nivel])
	detalle.text = "\n".join(lineas)
	boton_menu.hide()
	boton_continuar.grab_focus()

func mostrar_derrota(game_over: bool, jefe: bool) -> void:
	if game_over:
		titulo.text = "Game Over"
		detalle.text = "El jefe acabó con tu equipo." if jefe else "Tu equipo no puede seguir."
		boton_continuar.hide()
		boton_menu.grab_focus()
		return
	titulo.text = "Derrota"
	detalle.text = "Tu equipo se retira malherido.\nVida del equipo: %d" % Equipo.vida_total()
	boton_menu.hide()
	boton_continuar.grab_focus()
