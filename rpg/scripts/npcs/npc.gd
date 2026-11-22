extends CharacterBody2D
class_name Npc

const OpcionDialogo = preload("res://scripts/recursos/recurso_opcion_dialogo.gd")

@export var datos: RecursoNpc

@export_file("*.tscn") var escena_combate: String = "res://scenes/battle_arena.tscn"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var reputacion: ComponenteReputacion = $ComponenteReputacion
@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var area_vision: Area2D = $AreaVision
@onready var indicador: Sprite2D = $IndicadorInteraccion

var nombre: String = ""
var lineas: Array[String] = []
var opciones: Array[OpcionDialogo] = []
var _jugadores: Array[Node2D] = []
var _jugador_a_la_vista := false
var atacando := false
var persiguiendo := false
var distancia_contacto: float = 64.0
var _tregua := false
var _objetivo: Node2D

func _ready() -> void:
	if datos and Encuentros.derrotado(clave()):
		queue_free()
		return
	indicador.hide()
	area_interaccion.area_entered.connect(_al_entrar)
	area_interaccion.area_exited.connect(_al_salir)
	area_vision.body_entered.connect(_al_ver)
	area_vision.body_exited.connect(_al_perder_de_vista)
	reputacion.afinidad_cambiada.connect(_on_afinidad_cambiada)
	MotorDialogo.opcion_elegida.connect(_al_elegir_opcion)
	if datos == null:
		return
	_tregua = Encuentros.tomar_tregua(clave())
	if _tregua:
		get_tree().create_timer(0.5).timeout.connect(_revisar_tregua)
	nombre = datos.nombre
	if datos.sprite_frames:
		sprite.sprite_frames = datos.sprite_frames
		if datos.sprite_frames.has_animation("Idle"):
			sprite.play("Idle")
	reputacion.perfil = datos.perfil
	_actualizar_lineas()

func _process(_delta: float) -> void:
	indicador.visible = not _jugadores.is_empty() and tiene_dialogo() and not MotorDialogo.activo

func _physics_process(_delta: float) -> void:
	if not persiguiendo:
		return
	if atacando or not is_instance_valid(_objetivo) or MotorDialogo.activo or Transiciones.en_curso or GestorEventos.en_curso:
		velocity = Vector2.ZERO
		return
	var direccion = global_position.direction_to(_objetivo.global_position)
	velocity = direccion * datos.velocidad_persecucion
	move_and_slide()
	if sprite.sprite_frames.has_animation("Walk"):
		sprite.play("Walk")
	if direccion.x < -0.1:
		sprite.flip_h = true
	elif direccion.x > 0.1:
		sprite.flip_h = false
	if _toca_al_jugador():
		_atacar()

func _toca_al_jugador() -> bool:
	for i in get_slide_collision_count():
		var otro = get_slide_collision(i).get_collider()
		if otro and otro.is_in_group("Jugador"):
			return true
	return global_position.distance_to(_objetivo.global_position) <= distancia_contacto

func _reaccionar() -> void:
	if datos.sin_mente:
		persiguiendo = true
	else:
		_atacar()

func _on_afinidad_cambiada(_afinidad: float) -> void:
	_actualizar_lineas()
	if _jugador_a_la_vista and puede_atacar():
		_reaccionar()


func _al_elegir_opcion(opcion: OpcionDialogo) -> void:
	if not opciones.has(opcion) or opcion.miembro_party == null or not Equipo.miembros.has(opcion.miembro_party):
		return
	queue_free()


func _actualizar_lineas() -> void:
	lineas.clear()
	opciones.clear()
	match reputacion.estado:
		CalculoAlineamiento.Estado.AMISTOSO:
			lineas.append_array(datos.lineas_amistoso)
			opciones.append_array(datos.opciones_amistoso)
			return
		CalculoAlineamiento.Estado.HOSTIL:
			lineas.append_array(datos.lineas_hostil)
			opciones.append_array(datos.opciones_hostil)
		_:
			lineas.append_array(datos.lineas_indiferente)
			opciones.append_array(datos.opciones_indiferente)
	var eje = reputacion.resultado.get("eje")
	if eje == CalculoAlineamiento.Eje.LEY or eje == CalculoAlineamiento.Eje.AMBOS:
		lineas.append(datos.motivo_legal if Alineamiento.ley > datos.perfil.posicion_ley else datos.motivo_caotico)
	if eje == CalculoAlineamiento.Eje.BIEN or eje == CalculoAlineamiento.Eje.AMBOS:
		lineas.append(datos.motivo_bueno if Alineamiento.bien > datos.perfil.posicion_bien else datos.motivo_malvado)

func conoce_al_jugador() -> bool:
	return absf(Reputacion.reputacion_actual()) >= datos.umbral_conocimiento

func clave() -> StringName:
	if not datos.id.is_empty():
		return datos.id
	if owner:
		return StringName(owner.scene_file_path + ":" + name)
	return StringName(name)

func _revisar_tregua() -> void:
	if not _jugador_a_la_vista:
		_tregua = false

func puede_atacar() -> bool:
	if _tregua or datos == null or not datos.enemigos.any(func(e): return e != null):
		return false
	if datos.sin_mente:
		return true
	return reputacion.estado == CalculoAlineamiento.Estado.HOSTIL and conoce_al_jugador()


func obtener_retrato_dialogo() -> Texture2D:
	if sprite.sprite_frames == null or not sprite.sprite_frames.has_animation("Idle"):
		return null
	return sprite.sprite_frames.get_frame_texture("Idle", 0)

func _al_ver(cuerpo: Node2D) -> void:
	if not cuerpo.is_in_group("Jugador"):
		return
	_jugador_a_la_vista = true
	_objetivo = cuerpo
	if puede_atacar():
		_reaccionar()

func _al_perder_de_vista(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("Jugador"):
		_jugador_a_la_vista = false
		_tregua = false
		if persiguiendo and sprite.sprite_frames.has_animation("Idle"):
			sprite.play("Idle")
		persiguiendo = false

func _atacar() -> void:
	if atacando or Transiciones.en_curso:
		return
	atacando = true
	persiguiendo = false
	if not datos.sin_mente:
		MotorDialogo.iniciar(nombre, lineas, opciones, obtener_retrato_dialogo())
		if MotorDialogo.activo:
			await MotorDialogo.dialogo_finalizado
	var textura: Texture2D = null
	if sprite.sprite_frames and sprite.sprite_frames.get_frame_count(sprite.animation) > 0:
		textura = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	Encuentros.iniciar(datos.enemigos, clave(), escena_combate, nombre, textura)

func _al_entrar(area: Area2D) -> void:
	if area.is_in_group("InteraccionJugador") and not _jugadores.has(area):
		_jugadores.append(area)
		MotorDialogo.registrar(self)

func _al_salir(area: Area2D) -> void:
	_jugadores.erase(area)
	if _jugadores.is_empty():
		MotorDialogo.desregistrar(self)

func distancia_al_jugador() -> float:
	var distancia: float = INF
	for jugador in _jugadores:
		if is_instance_valid(jugador):
			distancia = minf(distancia, global_position.distance_squared_to(jugador.global_position))
	return distancia

func tiene_dialogo() -> bool:
	for linea in lineas:
		if not linea.strip_edges().is_empty():
			return true
	for opcion in opciones:
		if opcion == null:
			continue
		if opcion.flag_requerido.is_empty() or GestorEventos.obtener_flag(opcion.flag_requerido) == opcion.valor_flag_requerido:
			return true
	return false


func obtener_opciones_dialogo() -> Array[OpcionDialogo]:
	return opciones

func _exit_tree() -> void:
	if is_instance_valid(MotorDialogo):
		MotorDialogo.desregistrar(self)
