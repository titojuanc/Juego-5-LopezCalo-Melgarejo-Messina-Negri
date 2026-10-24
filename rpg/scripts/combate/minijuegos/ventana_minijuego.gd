extends CanvasLayer
class_name VentanaMinijuego

@export var escena_contundente: PackedScene
@export var escena_perforante: PackedScene
@export var escena_cortante: PackedScene
@export var multiplicador_fallo: float = 0.5
@export var multiplicador_bien: float = 1.0
@export var multiplicador_perfecto: float = 1.5
@export var demora_resultado: float = 1.2

@onready var titulo: Label = $Panel/Margen/Contenido/Titulo
@onready var sprite_enemigo: TextureRect = $Panel/Margen/Contenido/Escenario/Enemigo
@onready var zona: Control = $Panel/Margen/Contenido/Escenario/Zona
@onready var label_resultado: Label = $Panel/Margen/Contenido/Resultado

func _ready() -> void:
	hide()

func jugar(especial: RecursoAtaqueEspecial, objetivo: Node3D) -> float:
	var escena := _escena_para(especial.tipo_ataque)
	if escena == null:
		return 1.0
	var minijuego: MinijuegoAtaque = escena.instantiate()
	minijuego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	titulo.text = "%s: %s" % [especial.nombre, minijuego.instruccion]
	label_resultado.text = ""
	sprite_enemigo.texture = objetivo.visual.texture if objetivo is PersonajeEnemigo else null
	show()
	zona.add_child(minijuego)

	var resultado: MinijuegoAtaque.Resultado = await minijuego.terminado
	var multiplicador := _multiplicador_resultado(resultado)
	var texto := _texto_resultado(resultado)
	if objetivo is PersonajeEnemigo and objetivo.datos:
		var multiplicador_tipo: float = objetivo.datos.multiplicador_contra(especial.tipo_ataque)
		multiplicador *= multiplicador_tipo
		if multiplicador_tipo > 1.0:
			texto += "  ¡Es débil!"
		elif multiplicador_tipo < 1.0:
			texto += "  Lo resiste..."
	label_resultado.text = texto

	await get_tree().create_timer(demora_resultado).timeout
	minijuego.queue_free()
	hide()
	return multiplicador

func _escena_para(tipo: RecursoAtaqueEspecial.TipoAtaque) -> PackedScene:
	match tipo:
		RecursoAtaqueEspecial.TipoAtaque.CONTUNDENTE:
			return escena_contundente
		RecursoAtaqueEspecial.TipoAtaque.PERFORANTE:
			return escena_perforante
		RecursoAtaqueEspecial.TipoAtaque.CORTANTE:
			return escena_cortante
	return null

func _multiplicador_resultado(resultado: MinijuegoAtaque.Resultado) -> float:
	match resultado:
		MinijuegoAtaque.Resultado.PERFECTO:
			return multiplicador_perfecto
		MinijuegoAtaque.Resultado.BIEN:
			return multiplicador_bien
	return multiplicador_fallo

func _texto_resultado(resultado: MinijuegoAtaque.Resultado) -> String:
	match resultado:
		MinijuegoAtaque.Resultado.PERFECTO:
			return "¡PERFECTO!"
		MinijuegoAtaque.Resultado.BIEN:
			return "Bien"
	return "Fallaste"
