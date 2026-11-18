extends "res://scripts/niveles/puerta.gd"

# Puerta de salida del ascensor: su destino depende del piso elegido en el panel.
# El flag funciona como "piso actual": false = planta baja, true = primer piso.

@export var flag_piso: StringName = &"ascensor_piso_1"

@export_group("Planta baja")
@export_file("*.tscn") var escena_planta_baja: String = ""
@export var puerta_planta_baja: StringName = &""

@export_group("Primer piso")
@export_file("*.tscn") var escena_piso_1: String = ""
@export var puerta_piso_1: StringName = &""


func _ready() -> void:
	super()
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	_actualizar_destino()


func _al_cambiar_flag(nombre: StringName, _valor: bool) -> void:
	if nombre == flag_piso:
		_actualizar_destino()


func _actualizar_destino() -> void:
	if GestorEventos.obtener_flag(flag_piso):
		escena_destino = escena_piso_1
		puerta_destino = puerta_piso_1
	else:
		escena_destino = escena_planta_baja
		puerta_destino = puerta_planta_baja
