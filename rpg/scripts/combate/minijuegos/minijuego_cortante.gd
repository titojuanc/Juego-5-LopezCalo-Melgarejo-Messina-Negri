extends MinijuegoAtaque
class_name MinijuegoCortante

@export var cantidad_cortes: int = 3
@export var largo_corte: float = 0.55
@export var tolerancia: float = 28.0
@export var muestras: int = 6
@export var largo_estela: int = 14
@export var color_pendiente: Color = Color(1, 1, 1, 0.8)
@export var color_cortado: Color = Color(1.0, 0.2, 0.2)
@export var color_estela: Color = Color(0.7, 0.9, 1.0)

var _cortes: Array[Dictionary] = []
var _estela: PackedVector2Array = []
var _arrastrando: bool = false

func _actualizar(_delta: float) -> void:
	if _cortes.is_empty() and size.x > 0.0:
		_generar_cortes()
	if not _arrastrando and not _estela.is_empty():
		_estela.remove_at(0)

func _generar_cortes() -> void:
	var largo := minf(size.x, size.y) * largo_corte
	for i in cantidad_cortes:
		var fila := (i - (cantidad_cortes - 1) / 2.0) * size.y * 0.22
		var centro := size / 2.0 + Vector2(randf_range(-0.15, 0.15) * size.x, fila)
		var angulo := randf_range(-0.6, 0.6)
		if randf() < 0.5:
			angulo += PI / 2.0
		var mitad := Vector2.from_angle(angulo) * largo / 2.0
		var golpes: Array[bool] = []
		golpes.resize(muestras)
		golpes.fill(false)
		_cortes.append({"a": centro - mitad, "b": centro + mitad, "golpes": golpes, "hecho": false})

func _procesar_mouse(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_arrastrando = event.pressed
		_estela.clear()
		if event.pressed:
			_estela.append(event.position)
		else:
			_reiniciar_golpes()
	elif event is InputEventMouseMotion and _arrastrando:
		var anterior: Vector2 = _estela[_estela.size() - 1] if not _estela.is_empty() else event.position
		_estela.append(event.position)
		if _estela.size() > largo_estela:
			_estela.remove_at(0)
		_registrar_trazo(anterior, event.position)

func _registrar_trazo(desde: Vector2, hasta: Vector2) -> void:
	for corte in _cortes:
		if corte.hecho:
			continue
		var golpes: Array[bool] = corte.golpes
		for i in muestras:
			var muestra: Vector2 = corte.a.lerp(corte.b, i / float(muestras - 1))
			if Geometry2D.get_closest_point_to_segment(muestra, desde, hasta).distance_to(muestra) <= tolerancia:
				golpes[i] = true
		if not golpes.has(false):
			corte.hecho = true
	if _cantidad_hechos() == _cortes.size():
		_terminar(Resultado.PERFECTO)

func _reiniciar_golpes() -> void:
	for corte in _cortes:
		if not corte.hecho:
			corte.golpes.fill(false)

func _cantidad_hechos() -> int:
	return _cortes.filter(func(c): return c.hecho).size()

func _resultado_por_tiempo() -> Resultado:
	if _cantidad_hechos() * 2 >= _cortes.size():
		return Resultado.BIEN
	return Resultado.FALLO

func _draw() -> void:
	for corte in _cortes:
		if corte.hecho:
			draw_line(corte.a, corte.b, color_cortado, 8.0)
		else:
			draw_dashed_line(corte.a, corte.b, color_pendiente, 4.0, 14.0)
			draw_circle(corte.a, 6.0, color_pendiente)
			draw_circle(corte.b, 6.0, color_pendiente)
	if _estela.size() >= 2:
		draw_polyline(_estela, color_estela, 5.0, true)
	_dibujar_tiempo()
