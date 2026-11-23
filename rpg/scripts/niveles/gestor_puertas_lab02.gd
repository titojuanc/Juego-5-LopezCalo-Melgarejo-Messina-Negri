extends Node

const Interactuable = preload("res://scripts/niveles/interactuable.gd")
const FLAG_CIERRE_COMPARTIDO: StringName = &"evento_cierre_lab"
const FLAG_CIERRE_LAB3: StringName = &"lab5_bloquea_lab2_lab3"
const FLAG_CIERRE_LAB4: StringName = &"lab5_bloquea_lab2_lab4"
const SOURCE_PAREDES: int = 0
const CELDAS_PUERTA_LAB3: Array[Vector2i] = [Vector2i(2, 0), Vector2i(2, 1)]
const CELDAS_PUERTA_LAB4: Array[Vector2i] = [Vector2i(15, 0), Vector2i(15, 1)]
const CELDAS_ATLAS_BLOQUEO_LAB3: Array[Vector2i] = [Vector2i(9, 7), Vector2i(9, 8)]
const CELDAS_ATLAS_BLOQUEO_LAB4: Array[Vector2i] = [Vector2i(13, 7), Vector2i(13, 8)]

@onready var _paredes: TileMapLayer = get_node("Paredes")
@onready var _pc: Interactuable = get_node("PC_Ascensor")
@onready var _lineas_pc_iniciales: Array[String] = _pc.lineas.duplicate()


func _ready() -> void:
	GestorEventos.flag_cambiado.connect(_al_cambiar_flag)
	_actualizar_puertas()
	_actualizar_dialogo_pc()


func _exit_tree() -> void:
	if is_instance_valid(GestorEventos) and GestorEventos.flag_cambiado.is_connected(_al_cambiar_flag):
		GestorEventos.flag_cambiado.disconnect(_al_cambiar_flag)


func _al_cambiar_flag(nombre: StringName, _valor: bool) -> void:
	if nombre == FLAG_CIERRE_LAB3 or nombre == FLAG_CIERRE_LAB4:
		_actualizar_puertas()
	if nombre == FLAG_CIERRE_COMPARTIDO:
		_actualizar_dialogo_pc()


func _actualizar_dialogo_pc() -> void:
	_pc.lineas.assign(_lineas_pc_iniciales)
	if GestorEventos.obtener_flag(FLAG_CIERRE_COMPARTIDO):
		_pc.lineas[-1] = "Los botones de desbloqueo ahora aparecen disponibles."


func _actualizar_puertas() -> void:
	_actualizar_puerta(FLAG_CIERRE_LAB3, CELDAS_PUERTA_LAB3, CELDAS_ATLAS_BLOQUEO_LAB3)
	_actualizar_puerta(FLAG_CIERRE_LAB4, CELDAS_PUERTA_LAB4, CELDAS_ATLAS_BLOQUEO_LAB4)


func _actualizar_puerta(flag: StringName, celdas: Array[Vector2i], atlas_cerrado: Array[Vector2i]) -> void:
	for indice in celdas.size():
		var celda: Vector2i = celdas[indice]
		if GestorEventos.obtener_flag(flag):
			_paredes.set_cell(celda, SOURCE_PAREDES, atlas_cerrado[indice])
		else:
			_paredes.erase_cell(celda)
