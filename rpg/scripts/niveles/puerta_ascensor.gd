extends "res://scripts/niveles/puerta.gd"

enum Piso { LABORATORIO, PRIMER_PISO, SUBSUELO }

const FLAG_PRIMER_PISO := &"ascensor_piso_1"
const FLAG_SUBSUELO := &"ascensor_subsuelo"

@export_group("Laboratorio")
@export_file("*.tscn") var escena_planta_baja: String = ""
@export var puerta_planta_baja: StringName = &""

@export_group("Primer piso")
@export_file("*.tscn") var escena_piso_1: String = ""
@export var puerta_piso_1: StringName = &""

@export_group("Subsuelo")
@export_file("*.tscn") var escena_subsuelo: String = ""
@export var puerta_subsuelo: StringName = &""


func _ready() -> void:
	super()
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	_actualizar_destino()


func _al_cambiar_flag(nombre: StringName, _valor: bool) -> void:
	if nombre == FLAG_PRIMER_PISO or nombre == FLAG_SUBSUELO:
		_actualizar_destino()


func piso_actual() -> Piso:
	if GestorEventos.obtener_flag(FLAG_SUBSUELO):
		return Piso.SUBSUELO
	if GestorEventos.obtener_flag(FLAG_PRIMER_PISO):
		return Piso.PRIMER_PISO
	return Piso.LABORATORIO


func elegir_piso(piso: Piso) -> void:
	GestorEventos.cambiar_flag(FLAG_PRIMER_PISO, piso == Piso.PRIMER_PISO)
	GestorEventos.cambiar_flag(FLAG_SUBSUELO, piso == Piso.SUBSUELO)


func _actualizar_destino() -> void:
	match piso_actual():
		Piso.SUBSUELO:
			escena_destino = escena_subsuelo
			puerta_destino = puerta_subsuelo
		Piso.PRIMER_PISO:
			escena_destino = escena_piso_1
			puerta_destino = puerta_piso_1
		Piso.LABORATORIO:
			escena_destino = escena_planta_baja
			puerta_destino = puerta_planta_baja
