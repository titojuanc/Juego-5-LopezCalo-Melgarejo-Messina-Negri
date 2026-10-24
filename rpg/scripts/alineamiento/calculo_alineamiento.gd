extends RefCounted
class_name CalculoAlineamiento

enum Estado {HOSTIL, INDIFERENTE, AMISTOSO}
enum Eje {NINGUNO, LEY, BIEN, AMBOS}

static func calcular(perfil: RecursoPerfilAlineamiento, ley: float, bien: float, config: RecursoConfigAlineamiento) -> Dictionary:
	var dl := absf(ley - perfil.posicion_ley)
	var db := absf(bien - perfil.posicion_bien)
	var pen_ley := perfil.peso_ley * maxf(0.0, dl - perfil.umbral_ley)
	var pen_bien := perfil.peso_bien * maxf(0.0, db - perfil.umbral_bien)
	var afinidad := clampf(perfil.afinidad_base - pen_ley - pen_bien, config.afinidad_minima, config.afinidad_maxima)
	return {
		"distancia_ley": dl,
		"distancia_bien": db,
		"penalizacion_ley": pen_ley,
		"penalizacion_bien": pen_bien,
		"afinidad": afinidad,
		"estado": estado_de(afinidad, config),
		"eje": eje_dominante(pen_ley, pen_bien)
	}

static func estado_de(afinidad: float, config: RecursoConfigAlineamiento) -> Estado:
	if afinidad >= config.umbral_amistoso:
		return Estado.AMISTOSO
	elif afinidad <= config.umbral_hostil:
		return Estado.HOSTIL
	return Estado.INDIFERENTE

static func eje_dominante(pen_ley: float, pen_bien: float) -> Eje:
	if is_zero_approx(pen_ley) and is_zero_approx(pen_bien):
		return Eje.NINGUNO
	if is_equal_approx(pen_ley, pen_bien):
		return Eje.AMBOS
	if pen_ley > pen_bien:
		return Eje.LEY
	return Eje.BIEN

static func casilla(valor: float, config: RecursoConfigAlineamiento) -> int:
	if valor > config.umbral_casilla:
		return 1
	elif valor < -config.umbral_casilla:
		return -1
	return 0

static func nombre_alineamiento(ley: float, bien: float, config: RecursoConfigAlineamiento) -> String:
	var l = casilla(ley, config)
	var b = casilla(bien, config)
	if l == 0 and b == 0:
		return "Neutral"
	var nombres_ley = ["Caótico", "Neutral", "Legal"]
	var nombres_bien = ["malvado", "neutral", "bueno"]
	return nombres_ley[l + 1] + " " + nombres_bien[b + 1]
