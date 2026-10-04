extends Node

const RUTA := "user://configuracion.cfg"

var volumen: float = 1.0
var pantalla_completa: bool = false
var vsync: bool = true

func _ready() -> void:
	cargar()
	aplicar()
	
func aplicar() -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(volumen))
	AudioServer.set_bus_mute(bus, volumen <= 0.0)
	
	if pantalla_completa:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volumen", volumen)
	config.set_value("video", "pantalla_completa", pantalla_completa)
	config.set_value("video", "vsync", vsync)
	config.save(RUTA)
	
func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(RUTA) != OK:
		return
	volumen = config.get_value("audio", "volumen", volumen)
	pantalla_completa = config.get_value("video", "pantalla_completa", pantalla_completa)
	vsync = config.get_value("video", "vsync", vsync)
	
	
