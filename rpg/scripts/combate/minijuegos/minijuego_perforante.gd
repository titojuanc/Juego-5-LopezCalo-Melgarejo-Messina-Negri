extends MinijuegoAtaque
class_name MinijuegoPerforante

@export var radio_punto: float = 26.0
@export var proporcion_perfecto: float = 0.4
@export var velocidad: float = 1.0
@export var amplitud: Vector2 = Vector2(0.35, 0.3)
@export var color_punto: Color = Color(1.0, 0.2, 0.2)
@export var color_estocada: Color = Color.WHITE

var _fase: float = 0.0
var _clic: Vector2 = Vector2(-1, -1)

func _iniciar() -> void:
	_fase = randf() * TAU

func _posicion_punto() -> Vector2:
	var t := _tiempo * velocidad
	var desvio := Vector2(sin(t * 1.3 + _fase) * amplitud.x * size.x, sin(t * 2.1 + _fase * 2.0) * amplitud.y * size.y)
	return size / 2.0 + desvio

func _procesar_mouse(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_clic = event.position
		var distancia := _clic.distance_to(_posicion_punto())
		if distancia <= radio_punto * proporcion_perfecto:
			_terminar(Resultado.PERFECTO)
		elif distancia <= radio_punto:
			_terminar(Resultado.BIEN)
		else:
			_terminar(Resultado.FALLO)

func _draw() -> void:
	var punto := _posicion_punto()
	draw_circle(punto, radio_punto, Color(color_punto, 0.5))
	draw_arc(punto, radio_punto, 0, TAU, 48, color_punto, 3.0)
	draw_circle(punto, radio_punto * proporcion_perfecto, color_punto)
	if _clic.x >= 0.0:
		draw_line(Vector2(size.x / 2.0, size.y), _clic, color_estocada, 5.0)
		draw_circle(_clic, 6.0, color_estocada)
	_dibujar_tiempo()
