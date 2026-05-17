extends Node2D

enum CombatTier {
	EARLY,
	MID,
	LATE,
	BOSS
}

@export var combat_tier : CombatTier = (
	CombatTier.EARLY
)

const ENEMY_SCENE := preload(
	"res://entities/enemy/enemy.tscn"
)

var formations := {}

var current_enemies : Array = []

@onready var enemy_container : Node2D = (
	$EnemyContainer
)

@onready var spawn_points : Array = [
	$SpawnPoints/Spawn1,
	$SpawnPoints/Spawn2,
	$SpawnPoints/Spawn3
]

func _ready() -> void:

	randomize()

	_setup_formations()

	generate_combat()

	start_combat()

func _setup_formations() -> void:

	var cat_alien : EnemyData = preload(
		"res://entities/enemy/cat_alien/cat_alien.tres"
	)

	var bat_laser : EnemyData = preload(
		"res://entities/enemy/batlaser/batlaser.tres"
	)

	var bee : EnemyData = preload(
		"res://entities/enemy/bee/bee.tres"
	)

	var caristan : EnemyData = preload(
		"res://entities/enemy/caristan/caristan.tres"
	)

	var hezequiah : EnemyData = preload(
		"res://entities/enemy/hezequiah/hezequiah.tres"
	)

	formations = {

		CombatTier.EARLY: [

			{
				"weight": 70,
				"enemies": [
					bee
				]
			},

			{
				"weight": 30,
				"enemies": [
					cat_alien
				]
			}
		],

		CombatTier.MID: [

			{
				"weight": 40,
				"enemies": [
					cat_alien,
					bee
				]
			},

			{
				"weight": 50,
				"enemies": [
					bat_laser
				]
			},

			{
				"weight": 10,
				"enemies": [
					bat_laser,
					bat_laser,
					bat_laser
				]
			}
		],

		CombatTier.LATE: [

			{
				"weight": 90,
				"enemies": [
					cat_alien,
					bat_laser,
					bee
				]
			},

			{
				"weight": 10,
				"enemies": [
					hezequiah
				]
			}
		],

		CombatTier.BOSS: [

			{
				"weight": 100,
				"enemies": [
					caristan
				]
			}
		]
	}

func generate_combat() -> void:

	var formation : Dictionary = (
		get_weighted_formation(
			formations[combat_tier]
		)
	)

	spawn_formation(
		formation["enemies"]
	)

func get_weighted_formation(
	formation_pool : Array
) -> Dictionary:

	var total_weight : int = 0

	for formation in formation_pool:

		total_weight += (
			formation["weight"]
		)

	var roll := randf_range(
		0,
		total_weight
	)

	var accumulated : int = 0

	for formation in formation_pool:

		accumulated += (
			formation["weight"]
		)

		if roll <= accumulated:

			return formation

	return formation_pool[0]

func spawn_formation(
	enemy_list : Array
) -> void:

	current_enemies.clear()

	for i in range(enemy_list.size()):

		var enemy_instance : Enemy = (
			ENEMY_SCENE.instantiate() as Enemy
		)

		enemy_instance.enemy_data = (
			enemy_list[i] as EnemyData
		)

		enemy_container.add_child(
			enemy_instance
		)

		enemy_instance.global_position = (
			spawn_points[i].global_position
		)

		enemy_instance.setup()

		current_enemies.append(
			enemy_instance
		)

func start_combat() -> void:

	print("Combat inicia")

	await start_enemy_turns()

func start_enemy_turns() -> void:

	for enemy in current_enemies:

		if enemy == null:
			continue

		if not is_instance_valid(enemy):
			continue

		await enemy.start_turn()

	check_combat_end()

func check_combat_end() -> void:

	current_enemies = current_enemies.filter(
		func(enemy):
			return is_instance_valid(enemy)
	)

	if current_enemies.is_empty():

		print("Victoria")

		return_to_map()

func return_to_map() -> void:

	get_tree().change_scene_to_file(
		"res://stages/map/map.tscn"
	)
