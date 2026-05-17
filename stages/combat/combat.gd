extends Node2D
class_name CombatManager

signal jugador_selecciona_enemigo
signal ataque_iniciado

enum StageType {
	EARLY,
	MID,
	LATE,
	BOSS
}

const BATLASER = preload("res://entities/enemy/especific_enemies/batlaser.tres")
const BEE = preload("res://entities/enemy/especific_enemies/bee.tres")
const CAT_ALIEN = preload("res://entities/enemy/especific_enemies/cat_alien.tres")
const CARISTAN = preload("res://entities/enemy/especific_enemies/caristan.tres")
const HEZEQUIAH = preload("res://entities/enemy/especific_enemies/hezequiah.tres")

@export var current_stage : StageType = StageType.EARLY

var turno_jugador : bool = true
var puede_abrir_menu : bool = true

var personaje_seleccionado
var personaje_objetivo

var enemigos : Array = []
var jugadores : Array = []

var turno_enemigo : int = 0
var current_selected_enemy : Enemy = null

@onready var midground : Node2D = $Midground
@onready var enemy_container : Node2D = $EnemyContainer
@onready var enemy_spawn_1 : Marker2D = $Midground/EnemySpawn1
@onready var enemy_spawn_2 : Marker2D = $Midground/EnemySpawn2
@onready var enemy_spawn_3 : Marker2D = $Midground/EnemySpawn3
@onready var main_scene = $Camera2D/Main

var enemy_scene : PackedScene = preload("res://entities/enemy/enemy.tscn")

var early_formations : Array = [
	{
		"weight": 50,
		"enemies": [BATLASER]
	},
	{
		"weight": 35,
		"enemies": [BATLASER, BEE]
	},
	{
		"weight": 15,
		"enemies": [BEE, BEE, BATLASER]
	}
]

var mid_formations : Array = [
	{
		"weight": 50,
		"enemies": [CAT_ALIEN, BEE]
	},
	{
		"weight": 50,
		"enemies": [CARISTAN, BEE, BATLASER]
	}
]

var late_formations : Array = []

var boss_formations : Array = [
	{
		"weight": 100,
		"enemies": [HEZEQUIAH]
	}
]

func _ready() -> void:
	randomize()
	spawn_enemy_formation()
	await get_tree().process_frame
	enemigos = get_tree().get_nodes_in_group("enemies")
	jugadores = get_tree().get_nodes_in_group("player")

func get_stage_formations() -> Array:
	match current_stage:
		StageType.EARLY:
			return early_formations
		StageType.MID:
			return mid_formations
		StageType.LATE:
			return late_formations
		StageType.BOSS:
			return boss_formations
	return []

func get_random_formation() -> Dictionary:
	var formations : Array = get_stage_formations()
	var total_weight : int = 0

	for formation in formations:
		total_weight += formation["weight"]

	var rng : int = randi_range(1, total_weight)
	var accumulated : int = 0

	for formation in formations:
		accumulated += formation["weight"]
		if rng <= accumulated:
			return formation
	return {}

func spawn_enemy_formation() -> void:
	var formation : Dictionary = get_random_formation()

	if formation.is_empty():
		push_error("No se encontro formacion")
		return

	var enemies_data : Array = formation["enemies"]
	var spawns : Array[Marker2D] = [
		enemy_spawn_1,
		enemy_spawn_2,
		enemy_spawn_3
	]

	for i in enemies_data.size():
		if i >= spawns.size():
			break

		var enemy_instance : Enemy = enemy_scene.instantiate()
		enemy_container.add_child(enemy_instance)
		enemy_instance.global_position = spawns[i].global_position
		
		enemy_instance.z_index = 10
		enemy_instance.scale = Vector2(0.8, 0.8)
		
		enemy_instance.enemy_data = enemies_data[i]
		enemy_instance.setup()
		
		if not enemy_instance.is_connected("selected", _on_enemy_selected):
			enemy_instance.connect("selected", _on_enemy_selected)

func _on_enemy_selected(new_enemy: Enemy) -> void:
	if current_selected_enemy == new_enemy:
		return

	if current_selected_enemy != null and is_instance_valid(current_selected_enemy):
		current_selected_enemy.set_selected(false)

	current_selected_enemy = new_enemy
	current_selected_enemy.set_selected(true)
	establecer_objetivo(new_enemy)
	print("Nuevo enemigo seleccionado de forma fija: ", new_enemy.enemy_data.enemy_name)

func get_current_target() -> Enemy:
	if is_instance_valid(current_selected_enemy):
		return current_selected_enemy
	return null

func cambiar_turno() -> void:
	turno_jugador = !turno_jugador

func mostrar_seleccion() -> void:
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")

func establecer_personaje(personaje) -> void:
	personaje_seleccionado = personaje

func establecer_objetivo(personaje) -> void:
	personaje_objetivo = personaje

func iniciar_ataque() -> void:
	emit_signal("ataque_iniciado")
	personaje_seleccionado.atacar_personaje(personaje_objetivo)

func iniciar_turno_enemigo() -> void:
	if enemigos.is_empty():
		return

	if turno_enemigo >= enemigos.size():
		turno_enemigo = 0

	var enemigo_actual : Enemy = enemigos[turno_enemigo]

	if enemigo_actual == null:
		turno_enemigo += 1
		return

	print("Inicia turno de: " + enemigo_actual.enemy_data.enemy_name)
	await enemigo_actual.start_turn()
	turno_enemigo += 1
