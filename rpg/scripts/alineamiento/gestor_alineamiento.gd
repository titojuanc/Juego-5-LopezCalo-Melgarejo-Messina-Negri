extends Node
class_name GestorAlineamiento

signal alineamiento_cambiado(ley: float, bien: float)

var config: RecursoConfigAlineamiento = preload("res://scenes/alineamiento/config_alineamiento.tres")

var ley: float = 0.0
var bien: float = 0.0

func _ready() -> void:
	Performance.add_custom_monitor("Alineamiento/Ley-Caos", func(): return ley)
	Performance.add_custom_monitor("Alineamiento/Bien-Mal", func(): return bien)

func _exit_tree() -> void:
	Performance.remove_custom_monitor("Alineamiento/Ley-Caos")
	Performance.remove_custom_monitor("Alineamiento/Bien-Mal")

func aplicar_accion(accion: RecursoAccionMoral) -> void:
	if accion == null:
		return
	desplazar(accion.desplazamiento_ley, accion.desplazamiento_bien)

func desplazar(delta_ley: float, delta_bien: float) -> void:
	establecer(ley + delta_ley, bien + delta_bien)

func establecer(nueva_ley: float, nuevo_bien: float) -> void:
	nueva_ley = clampf(nueva_ley, -1.0, 1.0)
	nuevo_bien = clampf(nuevo_bien, -1.0, 1.0)
	if is_equal_approx(nueva_ley, ley) and is_equal_approx(nuevo_bien, bien):
		return
	ley = nueva_ley
	bien = nuevo_bien
	alineamiento_cambiado.emit(ley, bien)

func calcular(perfil: RecursoPerfilAlineamiento) -> Dictionary:
	return CalculoAlineamiento.calcular(perfil, ley, bien, config)

func nombre_actual() -> String:
	return CalculoAlineamiento.nombre_alineamiento(ley, bien, config)

func a_diccionario() -> Dictionary:
	return {"ley": ley, "bien": bien}

func desde_diccionario(datos: Dictionary) -> void:
	establecer(datos.get("ley", 0.0), datos.get("bien", 0.0))
