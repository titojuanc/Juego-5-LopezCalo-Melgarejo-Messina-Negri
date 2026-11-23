extends Node
class_name GestorEquipo

signal equipo_cambiado
signal nivel_subido(miembro: RecursoPersonajeCombate, nivel: int)

var maximo: int = 3

var nivel_maximo: int = 99

var penalizacion_derrota: float = 0.5

var miembros: Array[RecursoPersonajeCombate] = []

var inventario: Array[RecursoItem] = []

var oro: int = 0

var _progreso: Dictionary = {}

func establecer(nuevos: Array[RecursoPersonajeCombate]) -> void:
	miembros = nuevos.slice(0, maximo)
	inventario.clear()
	for miembro in miembros:
		inventario.append_array(miembro.inventario)
	equipo_cambiado.emit()

func agregar(miembro: RecursoPersonajeCombate) -> bool:
	if miembro == null or miembros.has(miembro) or miembros.size() >= maximo:
		return false
	miembros.append(miembro)
	inventario.append_array(miembro.inventario)
	equipo_cambiado.emit()
	return true

func agregar_items(nuevos: Array[RecursoItem]) -> void:
	if nuevos.is_empty():
		return
	for item in nuevos:
		if item != null:
			inventario.append(item)
	equipo_cambiado.emit()

func quitar(miembro: RecursoPersonajeCombate) -> void:
	if not miembros.has(miembro):
		return
	miembros.erase(miembro)
	equipo_cambiado.emit()

func lider() -> RecursoPersonajeCombate:
	if miembros.is_empty():
		return null
	return miembros[0]

func seguidores() -> Array:
	return miembros.slice(1)

func reclutado_antes(primero: RecursoPersonajeCombate, segundo: RecursoPersonajeCombate) -> bool:
	var indice_primero := miembros.find(primero)
	var indice_segundo := miembros.find(segundo)
	return indice_primero != -1 and indice_segundo != -1 and indice_primero <indice_segundo

func progreso_de(miembro: RecursoPersonajeCombate) -> Dictionary:
	if not _progreso.has(miembro):
		_progreso[miembro] = {"nivel": 1, "exp": 0, "vida": miembro.vida_max}
	return _progreso[miembro]

func arma_de(miembro: RecursoPersonajeCombate) -> RecursoArma:
	var ruta = progreso_de(miembro).get("arma", "")
	if ruta is String and not ruta.is_empty():
		return load(ruta) as RecursoArma
	return miembro.arma

func equipar_si_mejor(miembro: RecursoPersonajeCombate, arma: RecursoArma) -> void:
	if miembro == null or arma == null:
		return
	var actual := arma_de(miembro)
	if actual == null or arma.daño > actual.daño:
		progreso_de(miembro).arma = arma.resource_path

func vida_actual_de(miembro: RecursoPersonajeCombate) -> int:
	return clampi(progreso_de(miembro).get("vida", vida_max_de(miembro)), 0, vida_max_de(miembro))

func fijar_vida(miembro: RecursoPersonajeCombate, vida: int) -> void:
	progreso_de(miembro).vida = clampi(vida, 0, vida_max_de(miembro))

func vida_total() -> int:
	var total := 0
	for miembro in miembros:
		total += vida_actual_de(miembro)
	return total

func aplicar_derrota() -> bool:
	for miembro in miembros:
		fijar_vida(miembro, vida_actual_de(miembro) - ceili(vida_max_de(miembro) * penalizacion_derrota))
	return vida_total() <= 0

func nivel_de(miembro: RecursoPersonajeCombate) -> int:
	return progreso_de(miembro).nivel

func exp_para_subir(nivel: int) -> int:
	return 50 * nivel

func dar_experiencia(miembro: RecursoPersonajeCombate, cantidad: int) -> void:
	var progreso = progreso_de(miembro)
	progreso.exp += cantidad
	while progreso.nivel < nivel_maximo and progreso.exp >= exp_para_subir(progreso.nivel):
		progreso.exp -= exp_para_subir(progreso.nivel)
		progreso.nivel += 1
		fijar_vida(miembro, vida_actual_de(miembro) + miembro.vida_por_nivel)
		nivel_subido.emit(miembro, progreso.nivel)

func vida_max_de(miembro: RecursoPersonajeCombate) -> int:
	return miembro.vida_max + miembro.vida_por_nivel * (nivel_de(miembro) - 1)

func ataque_extra_de(miembro: RecursoPersonajeCombate) -> int:
	return miembro.ataque_por_nivel * (nivel_de(miembro) - 1)

func energia_max_de(miembro: RecursoPersonajeCombate) -> int:
	return miembro.energia_max + miembro.energia_por_nivel * (nivel_de(miembro) - 1)

func agregar_oro(cantidad: int) -> void:
	oro += cantidad

func agregar_item(item: RecursoItem) -> void:
	if item:
		inventario.append(item)

func usar_item(item: RecursoItem, miembro: RecursoPersonajeCombate) -> bool:
	if item == null or not inventario.has(item) or item.tipo != RecursoItem.TipoItem.HP:
		return false
	if vida_actual_de(miembro) >= vida_max_de(miembro):
		return false
	fijar_vida(miembro, vida_actual_de(miembro) + item.valor)
	inventario.erase(item)
	return true

func descartar_item(item: RecursoItem) -> void:
	inventario.erase(item)

func reiniciar() -> void:
	miembros.clear()
	inventario.clear()
	oro = 0
	_progreso.clear()

func a_diccionario() -> Dictionary:
	var progreso := {}
	for miembro in _progreso:
		progreso[miembro.resource_path] = _progreso[miembro].duplicate()
	return {
		"miembros": miembros.map(func(m): return m.resource_path),
		"inventario": inventario.map(func(i): return i.resource_path),
		"oro": oro,
		"progreso": progreso
	}

func desde_diccionario(datos: Dictionary) -> void:
	var nuevos: Array[RecursoPersonajeCombate] = []
	for ruta in datos.get("miembros", []):
		var miembro = load(ruta)
		if miembro is RecursoPersonajeCombate:
			nuevos.append(miembro)
	establecer(nuevos)
	inventario.clear()
	for ruta in datos.get("inventario", []):
		var item = load(ruta)
		if item is RecursoItem:
			inventario.append(item)
	oro = datos.get("oro", 0)
	_progreso.clear()
	var progreso: Dictionary = datos.get("progreso", {})
	for ruta in progreso:
		var miembro = load(ruta)
		if miembro is RecursoPersonajeCombate:
			_progreso[miembro] = progreso[ruta].duplicate()
