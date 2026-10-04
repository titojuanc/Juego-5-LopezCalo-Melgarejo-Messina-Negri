extends Control
class_name MinijuegoAtaque

signal terminado(resultado: Resultado)

enum Resultado {FALLO, BIEN, PERFECTO}

@export var instruccion: String
@export var duracion: float = 2.0
@export var color_tiempo: Color = Color(1, 1, 1, 0.8)

var _activo: bool = false
var _tiempo: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_activo = true
	_iniciar()

func _process(delta: float) -> void:
	if not _activo:
		return
	_tiempo += delta
	_actualizar(delta)
	queue_redraw()
	if _activo and _tiempo >= duracion:
		_terminar(_resultado_por_tiempo())

func _gui_input(event: InputEvent) -> void:
	if not _activo:
		return
	_procesar_mouse(event)
	accept_event()

func progreso() -> float:
	return clampf(_tiempo / duracion, 0.0, 1.0)

func _terminar(resultado: Resultado) -> void:
	if not _activo:
		return
	_activo = false
	queue_redraw()
	terminado.emit(resultado)

func _dibujar_tiempo() -> void:
	var alto := 6.0
	draw_rect(Rect2(0, size.y - alto, size.x * (1.0 - progreso()), alto), color_tiempo)

func _iniciar() -> void:
	pass

func _actualizar(_delta: float) -> void:
	pass

func _procesar_mouse(_event: InputEvent) -> void:
	pass

func _resultado_por_tiempo() -> Resultado:
	return Resultado.FALLO
