extends Node2D
class_name Player

@export var player_name : String = "Player"
@export var max_health : int = 100

var health : int
var is_busy : bool = false

@onready var health_bar : ProgressBar = $HealthBar
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state = animation_tree["parameters/playback"]

func _ready():

	health = max_health

	health_bar.max_value = max_health
	health_bar.value = health

	animation_tree.active = true

	play_idle()

func take_damage(amount : int):

	if is_busy:
		return

	is_busy = true

	health -= amount

	if health < 0:
		health = 0

	update_health_bar()

	play_hurt()

	print(player_name + " recibe ", amount, " daño")

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

	print(player_name + " recupera ", amount)

func update_health_bar():

	health_bar.value = health

func die():

	print(player_name + " muere")

	queue_free()

func play_idle():

	animation_state.travel("idle")

func play_hurt():

	animation_state.travel("hurt")
