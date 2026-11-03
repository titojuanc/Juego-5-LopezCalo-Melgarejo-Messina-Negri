extends MinijuegoAtaque
class_name MinijuegoCura

const TECLAS: Array[Key] = [KEY_D, KEY_F, KEY_J, KEY_K]
const LETRAS: Array[String] = ["D", "F", "J", "K"]

@export var cantidad_notas: int = 8
@export var preparacion: float = 2.0
@export var tiempo_caida: float = 0.5
@export var intervalo_notas: float = 0.45
@export var ventana_perfecto: float = 0.08
@export var ventana_bien: float = 0.2
@export var puntos_bien: float = 0.6
@export var ancho_carril: float = 70.0
@export var color_nota: Color = Color(0.3, 1.0, 0.5)
@export var color_perfecto: Color = Color(1.0, 0.9, 0.3)
@export var color_fallo: Color = Color(1.0, 0.3, 0.3)

class Nota:
	var carril: int
	var tiempo: float
	var resuelta: bool = false
	var resultado: Resultado = Resultado.FALLO

var _notas: Array[Nota] = []
var _destello: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _color_destello: Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]

func _iniciar() -> void:
	for i in cantidad_notas:
		var nota := Nota.new()
		nota.carril = randi() % TECLAS.size()
		nota.tiempo = tiempo_caida + i * intervalo_notas
		_notas.append(nota)
	duracion = preparacion + tiempo_caida + (cantidad_notas - 1) * intervalo_notas + ventana_bien + 0.4

func _tiempo_juego() -> float:
	return _tiempo - preparacion

func _actualizar(delta: float) -> void:
	for i in _destello.size():
		_destello[i] = maxf(0.0, _destello[i] - delta)
	var t := _tiempo_juego()
	for nota in _notas:
		if not nota.resuelta and t > nota.tiempo + ventana_bien:
			nota.resuelta = true
			_destello_en(nota.carril, color_fallo)
	puntaje = _calcular_puntaje()

func _input(event: InputEvent) -> void:
	if not _activo or _tiempo_juego() < 0.0:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var carril := TECLAS.find(event.physical_keycode)
		if carril >= 0:
			_golpear(carril)
			get_viewport().set_input_as_handled()

func _golpear(carril: int) -> void:
	var t := _tiempo_juego()
	for nota in _notas:
		if nota.resuelta or nota.carril != carril:
			continue
		var diferencia := absf(nota.tiempo - t)
		if diferencia > ventana_bien:
			return
		nota.resuelta = true
		if diferencia <= ventana_perfecto:
			nota.resultado = Resultado.PERFECTO
			_destello_en(carril, color_perfecto)
		else:
			nota.resultado = Resultado.BIEN
			_destello_en(carril, color_nota)
		return

func _destello_en(carril: int, color: Color) -> void:
	_destello[carril] = 0.25
	_color_destello[carril] = color

func _calcular_puntaje() -> float:
	var total := 0.0
	for nota in _notas:
		if nota.resuelta:
			if nota.resultado == Resultado.PERFECTO:
				total += 1.0
			elif nota.resultado == Resultado.BIEN:
				total += puntos_bien
	return total / maxf(1.0, _notas.size())

func _resultado_por_tiempo() -> Resultado:
	puntaje = _calcular_puntaje()
	if puntaje >= 0.85:
		return Resultado.PERFECTO
	if puntaje >= 0.45:
		return Resultado.BIEN
	return Resultado.FALLO

func _x_carril(carril: int) -> float:
	var total := ancho_carril * TECLAS.size()
	return (size.x - total) / 2.0 + carril * ancho_carril

func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	var y_golpe := size.y - 50.0
	var t := _tiempo_juego()
	for c in TECLAS.size():
		var x := _x_carril(c)
		draw_rect(Rect2(x + 2, 0, ancho_carril - 4, size.y), Color(1, 1, 1, 0.06))
		if _destello[c] > 0.0:
			draw_rect(Rect2(x + 2, 0, ancho_carril - 4, size.y), Color(_color_destello[c], _destello[c]))
	draw_line(Vector2(_x_carril(0), y_golpe), Vector2(_x_carril(TECLAS.size()), y_golpe), Color.WHITE, 3.0)
	for nota in _notas:
		if nota.resuelta:
			continue
		var avance: float = 1.0 - (nota.tiempo - t) / tiempo_caida
		if avance < 0.0:
			continue
		var y := y_golpe * avance
		draw_rect(Rect2(_x_carril(nota.carril) + 8, y - 8, ancho_carril - 16, 16), color_nota)
	for c in TECLAS.size():
		var x := _x_carril(c)
		draw_string(fuente, Vector2(x, y_golpe + 34), LETRAS[c], HORIZONTAL_ALIGNMENT_CENTER, ancho_carril, 28)
	if t < 0.0:
		draw_string(fuente, Vector2(0, size.y / 2.0), "¡Preparate! %.1f" % -t, HORIZONTAL_ALIGNMENT_CENTER, size.x, 32)
