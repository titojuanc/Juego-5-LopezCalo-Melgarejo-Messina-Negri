extends CanvasLayer

const COLOR_PANEL := Color("1a1730")
const COLOR_TARJETA := Color("241f42")
const COLOR_LINEA := Color("3a3366")
const COLOR_ORO := Color("e8b94a")
const COLOR_TEXTO := Color("ece8ff")
const COLOR_APAGADO := Color("9a93c4")
const COLOR_VIDA := Color("5fd38d")
const COLOR_EXP := Color("6aa8ff")

@onready var fondo: ColorRect = $Fondo
@onready var panel: PanelContainer = $Panel
@onready var boton_equipo: Button = $Panel/Margen/Contenido/Pestanas/BotonEquipo
@onready var boton_objetos: Button = $Panel/Margen/Contenido/Pestanas/BotonObjetos
@onready var pagina_equipo: HBoxContainer = $Panel/Margen/Contenido/PaginaEquipo
@onready var pagina_objetos: HBoxContainer = $Panel/Margen/Contenido/PaginaObjetos
@onready var lista: VBoxContainer = $Panel/Margen/Contenido/PaginaEquipo/Lista
@onready var resumen: Label = $Panel/Margen/Contenido/PaginaEquipo/Lado/Cuerpo/Resumen
@onready var items: VBoxContainer = $Panel/Margen/Contenido/PaginaObjetos/Items
@onready var nombre_item: Label = $Panel/Margen/Contenido/PaginaObjetos/Detalle/Cuerpo/NombreItem
@onready var efecto_item: Label = $Panel/Margen/Contenido/PaginaObjetos/Detalle/Cuerpo/EfectoItem
@onready var acciones: VBoxContainer = $Panel/Margen/Contenido/PaginaObjetos/Detalle/Cuerpo/Acciones
@onready var label_oro: Label = $Panel/Margen/Contenido/Pie/Oro

var _item: RecursoItem
var _boton_item: Button
var _en_acciones := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.theme = _crear_tema()
	panel.add_theme_stylebox_override("panel", _caja(COLOR_PANEL, COLOR_ORO, 3, 4))
	boton_equipo.pressed.connect(_mostrar_pagina.bind(true))
	boton_objetos.pressed.connect(_mostrar_pagina.bind(false))
	panel.hide()

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
	if evento.is_echo() or not panel.visible:
		return
	if evento.is_action_pressed("interactuar"):
		var foco = get_viewport().gui_get_focus_owner()
		if foco is Button and not foco.disabled:
			foco.pressed.emit()
		get_viewport().set_input_as_handled()
	elif evento.is_action_pressed("cancelar") or evento.is_action_pressed("ui_cancel"):
		if _en_acciones:
			_volver()
		else:
			cerrar()
		get_viewport().set_input_as_handled()

func _se_puede_abrir() -> bool:
	return GestorJugador.jugador.is_inside_tree() and not get_tree().paused and not MotorDialogo.activo and not Transiciones.en_curso and not GestorEventos.en_curso

func abrir() -> void:
	_refrescar()
	_mostrar_pagina(true)
	fondo.show()
	panel.show()
	boton_equipo.grab_focus()
	get_tree().paused = true

func cerrar() -> void:
	fondo.hide()
	panel.hide()
	get_tree().paused = false

func _mostrar_pagina(equipo: bool) -> void:
	_en_acciones = false
	pagina_equipo.visible = equipo
	pagina_objetos.visible = not equipo
	_marcar_pestana(boton_equipo, equipo)
	_marcar_pestana(boton_objetos, not equipo)
	if not equipo:
		_enfocar_objetos()

func _marcar_pestana(boton: Button, activa: bool) -> void:
	if activa:
		boton.add_theme_stylebox_override("normal", _caja(COLOR_ORO, COLOR_ORO, 2, 3))
		boton.add_theme_color_override("font_color", Color("1a1200"))
	else:
		boton.remove_theme_stylebox_override("normal")
		boton.remove_theme_color_override("font_color")

func _refrescar() -> void:
	_limpiar(lista)
	for miembro in Equipo.miembros:
		lista.add_child(_crear_tarjeta(miembro))
	label_oro.text = "Oro: %d" % Equipo.oro
	_limpiar(items)
	_limpiar(acciones)
	nombre_item.text = ""
	efecto_item.text = ""
	var cantidades := {}
	var orden := []
	for item in Equipo.inventario:
		if not cantidades.has(item):
			orden.append(item)
		cantidades[item] = cantidades.get(item, 0) + 1
	var lineas := []
	for item in orden:
		lineas.append("%s  x%d" % [item.nombre, cantidades[item]])
		var boton = Button.new()
		boton.text = lineas[-1]
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.focus_entered.connect(_mostrar_detalle.bind(item))
		boton.pressed.connect(_elegir_item.bind(item, boton))
		items.add_child(boton)
	if orden.is_empty():
		var vacio = Label.new()
		vacio.text = "No tenés objetos."
		items.add_child(vacio)
		lineas.append("No tenés objetos.")
	resumen.text = "\n".join(lineas)

func _crear_tarjeta(miembro: RecursoPersonajeCombate) -> PanelContainer:
	var progreso = Equipo.progreso_de(miembro)
	var arma = Equipo.arma_de(miembro)
	var dano_arma = arma.daño if arma else 0
	var vida = Equipo.vida_actual_de(miembro)
	var vida_max = Equipo.vida_max_de(miembro)
	var exp_max = Equipo.exp_para_subir(progreso.nivel)
	var tarjeta = PanelContainer.new()
	var fila = HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	tarjeta.add_child(fila)
	fila.add_child(_crear_retrato())
	var datos = VBoxContainer.new()
	datos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(datos)
	var cabecera = HBoxContainer.new()
	var nombre = _crear_label(miembro.nombre, 22)
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabecera.add_child(nombre)
	var nivel = _crear_label("Nv. %d" % progreso.nivel, 22)
	nivel.add_theme_color_override("font_color", COLOR_ORO)
	cabecera.add_child(nivel)
	datos.add_child(cabecera)
	datos.add_child(_crear_barra("Vida", vida, vida_max, COLOR_VIDA))
	datos.add_child(_crear_barra("EXP", progreso.exp, exp_max, COLOR_EXP))
	datos.add_child(_crear_label("Energía %d   Ataque %d" % [Equipo.energia_max_de(miembro), dano_arma + Equipo.ataque_extra_de(miembro)], 16))
	var por_nivel = _crear_label("Por nivel: +%d vida, +%d ataque, +%d energía" % [miembro.vida_por_nivel, miembro.ataque_por_nivel, miembro.energia_por_nivel], 14)
	por_nivel.add_theme_color_override("font_color", COLOR_APAGADO)
	datos.add_child(por_nivel)
	return tarjeta

func _crear_retrato() -> TextureRect:
	var retrato = TextureRect.new()
	var sprite: AnimatedSprite2D = GestorJugador.cuerpo.get_node("AnimatedSprite2D")
	retrato.texture = sprite.sprite_frames.get_frame_texture("Idle", 0)
	retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	retrato.custom_minimum_size = Vector2(96, 96)
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return retrato

func _crear_barra(titulo: String, valor: int, maximo: int, color: Color) -> HBoxContainer:
	var fila = HBoxContainer.new()
	var etiqueta = _crear_label(titulo, 16)
	etiqueta.custom_minimum_size.x = 50
	fila.add_child(etiqueta)
	var barra = ProgressBar.new()
	barra.max_value = maximo
	barra.value = valor
	barra.show_percentage = false
	barra.custom_minimum_size = Vector2(0, 14)
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	barra.add_theme_stylebox_override("background", _caja(Color("0f0d1a"), COLOR_LINEA, 1, 0))
	barra.add_theme_stylebox_override("fill", _caja(color, color, 0, 0))
	fila.add_child(barra)
	var numeros = _crear_label("%d / %d" % [valor, maximo], 16)
	numeros.custom_minimum_size.x = 90
	numeros.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fila.add_child(numeros)
	return fila

func _crear_label(texto: String, tamano: int) -> Label:
	var label = Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", tamano)
	return label

func _mostrar_detalle(item: RecursoItem) -> void:
	nombre_item.text = item.nombre
	efecto_item.text = _efecto(item)
	_limpiar(acciones)

func _efecto(item: RecursoItem) -> String:
	if item.tipo == RecursoItem.TipoItem.HP:
		return "Recupera %d de vida" % item.valor
	return "Solo se usa en combate"

func _elegir_item(item: RecursoItem, boton: Button) -> void:
	_item = item
	_boton_item = boton
	_en_acciones = true
	_bloquear_items(true)
	_mostrar_detalle(item)
	var usar = _agregar_accion("Usar", _elegir_objetivo)
	usar.disabled = item.tipo != RecursoItem.TipoItem.HP
	_agregar_accion("Descartar", _descartar)
	_agregar_accion("Cancelar", _volver)
	_enfocar_primera()

func _elegir_objetivo() -> void:
	_limpiar(acciones)
	efecto_item.text = "¿Quién usa %s?" % _item.nombre
	for miembro in Equipo.miembros:
		var texto = "%s  %d / %d" % [miembro.nombre, Equipo.vida_actual_de(miembro), Equipo.vida_max_de(miembro)]
		var boton = _agregar_accion(texto, _usar.bind(miembro))
		boton.disabled = Equipo.vida_actual_de(miembro) >= Equipo.vida_max_de(miembro)
	_agregar_accion("Cancelar", _volver)
	_enfocar_primera()

func _usar(miembro: RecursoPersonajeCombate) -> void:
	Equipo.usar_item(_item, miembro)
	_terminar_accion()

func _descartar() -> void:
	Equipo.descartar_item(_item)
	_terminar_accion()

func _terminar_accion() -> void:
	_en_acciones = false
	_refrescar()
	_enfocar_objetos()

func _volver() -> void:
	_en_acciones = false
	_bloquear_items(false)
	_mostrar_detalle(_item)
	if is_instance_valid(_boton_item):
		_boton_item.grab_focus()

func _bloquear_items(bloquear: bool) -> void:
	for hijo in items.get_children():
		if hijo is Button:
			hijo.focus_mode = Control.FOCUS_NONE if bloquear else Control.FOCUS_ALL

func _agregar_accion(texto: String, accion: Callable) -> Button:
	var boton = Button.new()
	boton.text = texto
	boton.pressed.connect(accion)
	acciones.add_child(boton)
	return boton

func _enfocar_primera() -> void:
	for boton in acciones.get_children():
		if not boton.disabled:
			boton.grab_focus.call_deferred()
			return

func _enfocar_objetos() -> void:
	if items.get_child_count() > 0 and items.get_child(0) is Button:
		items.get_child(0).grab_focus.call_deferred()
	else:
		boton_objetos.grab_focus.call_deferred()

func _limpiar(contenedor: Container) -> void:
	for hijo in contenedor.get_children():
		contenedor.remove_child(hijo)
		hijo.queue_free()

func _caja(relleno: Color, borde: Color, grosor: int, margen: int) -> StyleBoxFlat:
	var caja = StyleBoxFlat.new()
	caja.bg_color = relleno
	caja.border_color = borde
	caja.set_border_width_all(grosor)
	caja.set_corner_radius_all(3)
	caja.set_content_margin_all(margen)
	return caja

func _crear_tema() -> Theme:
	var tema = Theme.new()
	tema.set_stylebox("panel", "PanelContainer", _caja(COLOR_TARJETA, COLOR_LINEA, 2, 12))
	tema.set_color("font_color", "Label", COLOR_TEXTO)
	tema.set_color("font_color", "Button", COLOR_TEXTO)
	tema.set_color("font_disabled_color", "Button", COLOR_APAGADO)
	tema.set_color("font_focus_color", "Button", COLOR_ORO)
	tema.set_color("font_hover_color", "Button", COLOR_ORO)
	tema.set_stylebox("normal", "Button", _caja(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 2, 8))
	tema.set_stylebox("hover", "Button", _caja(COLOR_TARJETA, COLOR_LINEA, 2, 8))
	tema.set_stylebox("pressed", "Button", _caja(COLOR_TARJETA, COLOR_ORO, 2, 8))
	tema.set_stylebox("focus", "Button", _caja(COLOR_TARJETA, COLOR_ORO, 2, 8))
	tema.set_stylebox("disabled", "Button", _caja(Color(0, 0, 0, 0), COLOR_LINEA, 2, 8))
	return tema
