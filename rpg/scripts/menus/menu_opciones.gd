extends Control
class_name MenuOpciones

signal cerrado

@onready var slider_volumen: HSlider = $Panel/Margen/Contenido/FilaVolumen/SliderVolumen
@onready var label_volumen: Label = $Panel/Margen/Contenido/FilaVolumen/ValorVolumen
@onready var check_pantalla_completa: CheckButton = $Panel/Margen/Contenido/CheckPantallaCompleta
@onready var check_vsync: CheckButton = $Panel/Margen/Contenido/CheckVsync

func _ready() -> void:
	_cargar_valores()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()
	
func abrir() -> void:
	show()
	
func cerrar() -> void:
	Configuracion.guardar()
	hide()
	cerrado.emit()
	
func _on_visibilidad_cambiada() -> void:
	if visible:
		_cargar_valores()
		slider_volumen.grab_focus()
	
func _cargar_valores() -> void:
	slider_volumen.set_value_no_signal(Configuracion.volumen * 100.0)
	label_volumen.text = "%d%%" % roundi(slider_volumen.value)
	check_pantalla_completa.set_pressed_no_signal(Configuracion.pantalla_completa)
	check_vsync.set_pressed_no_signal(Configuracion.vsync)
	
func _on_volumen_cambiado(valor: float) -> void:
	Configuracion.volumen = valor / 100.0
	label_volumen.text = "%d%%" % roundi(valor)
	Configuracion.aplicar()
	
func _on_pantalla_completa_cambiada(activo: bool) -> void:
	Configuracion.pantalla_completa = activo
	Configuracion.aplicar()
	
func _on_vsync_cambiado(activo: bool) -> void:
	Configuracion.vsync = activo
	Configuracion.aplicar()
	
	
