extends CanvasLayer

@onready var fondo: ColorRect = $Fondo
@onready var panel: PanelContainer = $Panel
@onready var lista: VBoxContainer = $Panel/Margen/Contenido/Lista
@onready var label_oro: Label = $Panel/Margen/Contenido/Oro
@onready var items: VBoxContainer = $Panel/Margen/Contenido/Items
@onready var submenu: PanelContainer = $Submenu
@onready var titulo_submenu: Label = $Submenu/Margen/Contenido/Titulo
@onready var opciones: VBoxContainer = $Submenu/Margen/Contenido/Opciones

var _item: RecursoItem
var _boton_item: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()
	submenu.hide()

func _input(evento: InputEvent) -> void:
	if evento.is_echo() or not evento.is_action_pressed("menu_party"):
		return
	if panel.visible:
		cerrar()
	elif _se_puede_abrir():
		abrir()
	else:
		return
	get_viewport().set_input_as_handled()

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if panel.visible and evento.is_action_pressed("interactuar"):
		var foco = get_viewport().gui_get_focus_owner()
		if foco is Button and not foco.disabled:
			foco.pressed.emit()
		get_viewport().set_input_as_handled()
		return
	if panel.visible and (evento.is_action_pressed("cancelar") or evento.is_action_pressed("ui_cancel")):
		if submenu.visible:
			_cerrar_submenu()
		else:
			cerrar()
		get_viewport().set_input_as_handled()

func _se_puede_abrir() -> bool:
	return GestorJugador.jugador.is_inside_tree() and not get_tree().paused and not MotorDialogo.activo and not Transiciones.en_curso and not GestorEventos.en_curso

func abrir() -> void:
	_refrescar()
	fondo.show()
	panel.show()
	get_tree().paused = true

func cerrar() -> void:
	submenu.hide()
	fondo.hide()
	panel.hide()
	get_tree().paused = false

func _refrescar() -> void:
	for hijo in lista.get_children():
		hijo.queue_free()
	for miembro in Equipo.miembros:
		var label = Label.new()
		label.text = _texto_miembro(miembro)
		lista.add_child(label)
	label_oro.text = "Oro: %d" % Equipo.oro
	for hijo in items.get_children():
		items.remove_child(hijo)
		hijo.queue_free()
	var cantidades := {}
	var orden = []
	for item in Equipo.inventario:
		if not cantidades.has(item):
			orden.append(item)
		cantidades[item] = cantidades.get(item, 0) + 1
	if orden.is_empty():
		var vacio = Label.new()
		vacio.text = "No tenés objetos."
		items.add_child(vacio)
		return
	for item in orden:
		var boton = Button.new()
		boton.text = "%s x%d" % [item.nombre, cantidades[item]]
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.pressed.connect(_elegir_item.bind(item, boton))
		items.add_child(boton)
	items.get_child(0).grab_focus.call_deferred()

func _texto_miembro(miembro: RecursoPersonajeCombate) -> String:
	var progreso = Equipo.progreso_de(miembro)
	var dano_arma = miembro.arma.daño if miembro.arma else 0
	return "%s   Nv. %d   EXP %d / %d\nVida %d / %d   Ataque %d   Energía %d\nPor nivel: +%d vida, +%d ataque, +%d energía" % [
		miembro.nombre, progreso.nivel, progreso.exp, Equipo.exp_para_subir(progreso.nivel),
		Equipo.vida_actual_de(miembro), Equipo.vida_max_de(miembro), dano_arma + Equipo.ataque_extra_de(miembro), Equipo.energia_max_de(miembro),
		miembro.vida_por_nivel, miembro.ataque_por_nivel, miembro.energia_por_nivel
	]

func _efecto(item: RecursoItem) -> String:
	if item.tipo == RecursoItem.TipoItem.HP:
		return "Recupera %d de vida" % item.valor
	return "Solo se usa en combate"

func _elegir_item(item: RecursoItem, boton: Button) -> void:
	_item = item
	_boton_item = boton
	_limpiar_opciones()
	titulo_submenu.text = "%s\n%s" % [item.nombre, _efecto(item)]
	var usar = _agregar_opcion("Usar", _elegir_objetivo)
	usar.disabled = item.tipo != RecursoItem.TipoItem.HP
	_agregar_opcion("Descartar", _descartar)
	_agregar_opcion("Cancelar", _cerrar_submenu)
	submenu.show()
	submenu.reset_size()
	submenu.global_position = boton.global_position + Vector2(boton.size.x + 8, 0)
	_enfocar_primera()

func _elegir_objetivo() -> void:
	_limpiar_opciones()
	titulo_submenu.text = "¿Quién usa %s?" % _item.nombre
	for miembro in Equipo.miembros:
		var boton = _agregar_opcion("%s  %d / %d" % [miembro.nombre, Equipo.vida_actual_de(miembro), Equipo.vida_max_de(miembro)], _usar.bind(miembro))
		boton.disabled = Equipo.vida_actual_de(miembro) >= Equipo.vida_max_de(miembro)
	_agregar_opcion("Cancelar", _cerrar_submenu)
	submenu.reset_size()
	_enfocar_primera()

func _usar(miembro: RecursoPersonajeCombate) -> void:
	Equipo.usar_item(_item, miembro)
	submenu.hide()
	_refrescar()

func _descartar() -> void:
	Equipo.descartar_item(_item)
	submenu.hide()
	_refrescar()

func _agregar_opcion(texto: String, accion: Callable) -> Button:
	var boton = Button.new()
	boton.text = texto
	boton.pressed.connect(accion)
	opciones.add_child(boton)
	return boton

func _limpiar_opciones() -> void:
	for hijo in opciones.get_children():
		opciones.remove_child(hijo)
		hijo.queue_free()

func _enfocar_primera() -> void:
	for boton in opciones.get_children():
		if not boton.disabled:
			boton.grab_focus()
			return

func _cerrar_submenu() -> void:
	submenu.hide()
	if is_instance_valid(_boton_item):
		_boton_item.grab_focus()
