extends Node2D
class_name Enemy

@export var enemy_name : String = "Enemy"
@export var max_health : int = 100
@export var actions_per_turn : int = 1

var health : int
var current_turn : int = 0
var is_my_turn : bool = false
var is_busy : bool = false

var game_environment : Dictionary = {}

@onready var health_bar : ProgressBar = $HealthBar
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

func _ready():

	health = max_health

	health_bar.max_value = max_health
	health_bar.value = health

	animation_tree.active = true

	play_idle()

func set_turn(turn : int):

	if is_busy:
		return

	current_turn = turn

	if current_turn == 1:
		start_turn()

func start_turn():

	is_my_turn = true

	print(enemy_name + " inicia turno")

	await execute_turn_actions()

	end_turn()

func end_turn():

	is_my_turn = false

	print(enemy_name + " termina turno")

func execute_turn_actions():

	for i in range(actions_per_turn):

		if is_busy:
			return

		var selected_action = select_basic_action()

		match selected_action:

			"attack":
				await basic_attack()

			"heal":
				await basic_heal()

		await get_tree().create_timer(0.5).timeout

func select_basic_action() -> String:

	if health <= max_health * 0.4:

		var heal_probability = randi_range(1, 100)

		if heal_probability <= 50:
			return "heal"

	return "attack"

func basic_attack():

	is_busy = true

	print(enemy_name + " usa attack")

	play_attack()

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

func basic_heal():

	is_busy = true

	print(enemy_name + " usa heal")

	play_hurt()

	heal(10)

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

func take_damage(amount : int):

	if is_busy:
		return

	is_busy = true

	health -= amount

	if health < 0:
		health = 0

	update_health_bar()

	play_hurt()

	print(enemy_name + " recibe ", amount, " daño")

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

	if health <= 0:
		die()

func heal(amount : int):

	health += amount

	if health > max_health:
		health = max_health

	update_health_bar()

	print(enemy_name + " recupera ", amount)

func update_health_bar():

	health_bar.value = health

func die():

	print(enemy_name + " muere")

	queue_free()

func play_idle():

	animation_state.travel("idle")

func play_attack():

	animation_state.travel("attack")

func play_hurt():

	animation_state.travel("hurt")
