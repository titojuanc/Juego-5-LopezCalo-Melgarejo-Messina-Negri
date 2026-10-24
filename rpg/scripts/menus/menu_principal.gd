extends Control
class_name MenuPrincipal

@export_file("*.tscn") var escena_juego: String = "res://scenes/battle_arena.tscn"

@onready var botones: VBoxContainer = $Centro/Contenido/Botones
@onready var boton_jugar: Button = $Centro/Contenido/Botones/BotonJugar
@onready var boton_opciones: Button = $Centro/Contenido/Botones/BotonOpciones
@onready var boton_salir: Button = $Centro/Contenido/Botones/BotonSalir
@onready var menu_opciones: MenuOpciones = $MenuOpciones

func _ready() -> void:
	boton_salir.visible = not OS.has_feature("web")
	menu_opciones.hide()
	boton_jugar.grab_focus()
	
func _on_jugar_presionado() -> void:
	get_tree().change_scene_to_file(escena_juego)
	
func _on_opciones_presionado() -> void:
	botones.hide()
	menu_opciones.abrir()
	
func _on_opciones_cerrado() -> void:
	botones.show()
	boton_opciones.grab_focus()
	
func _on_salir_presionado() -> void:
	get_tree().quit()
	
	
