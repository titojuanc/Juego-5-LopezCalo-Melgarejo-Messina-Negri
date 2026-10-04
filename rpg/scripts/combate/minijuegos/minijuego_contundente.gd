extends MinijuegoAtaque
class_name MinijuegoContundente

@export var radio_objetivo: float = 40.0
@export var radio_inicial: float = 160.0
@export var tolerancia_perfecto: float = 8.0
@export var tolerancia_bien: float = 22.0
@export var color_objetivo: Color = Color.WHITE
@export var color_anillo: Color = Color(1.0, 0.6, 0.1)

var _radio_golpe: float = -1.0

func _radio_anillo() -> float:
	return lerpf(radio_inicial, 0.0, progreso())

func _actualizar(_delta: float) -> void:
	if _radio_anillo() < radio_objetivo - tolerancia_bien:
		_terminar(Resultado.FALLO)

func _procesar_mouse(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_radio_golpe = _radio_anillo()
		var diferencia := absf(_radio_golpe - radio_objetivo)
		if diferencia <= tolerancia_perfecto:
			_terminar(Resultado.PERFECTO)
		elif diferencia <= tolerancia_bien:
			_terminar(Resultado.BIEN)
		else:
			_terminar(Resultado.FALLO)

func _draw() -> void:
	var centro := size / 2.0
	draw_arc(centro, radio_objetivo, 0, TAU, 64, color_objetivo, 4.0)
	var radio := _radio_golpe if _radio_golpe >= 0.0 else _radio_anillo()
	draw_arc(centro, radio, 0, TAU, 64, color_anillo, 6.0)
	if _radio_golpe >= 0.0:
		draw_circle(centro, radio_objetivo, Color(color_anillo, 0.35))
	_dibujar_tiempo()
