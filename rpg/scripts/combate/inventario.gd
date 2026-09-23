extends Node
class_name Inventario

signal item_usado(item: RecursoItem)

var items: Array[RecursoItem] = []

func inicializar(datos: RecursoPersonajeCombate) -> void:
	items = datos.inventario.duplicate()

func usar_item(indice: int, salud_objetivo: Salud, combate_objetivo: Combate) -> void:
	if indice < 0 or indice >= items.size():
		return
	var item := items[indice]
	if item.tipo == RecursoItem.TipoItem.HP:
		salud_objetivo.curar(item.valor)
	elif item.tipo == RecursoItem.TipoItem.ATK_UP:
		combate_objetivo.bonus_ataque += item.valor / 100.0
	elif item.tipo == RecursoItem.TipoItem.ATK_DOWN:
		combate_objetivo.bonus_ataque -= item.valor / 100.0
	elif item.tipo == RecursoItem.TipoItem.DEF_UP:
		salud_objetivo.bonus_defensa -= item.valor / 100.0
	elif item.tipo == RecursoItem.TipoItem.DEF_DOWN:
		salud_objetivo.bonus_defensa += item.valor / 100.0
	items.remove_at(indice)
	item_usado.emit(item)
