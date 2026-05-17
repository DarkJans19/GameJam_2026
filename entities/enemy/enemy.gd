extends Node2D
class_name Enemy

enum LunarPhase {
	NEW_MOON,
	WAXING_CRESCENT,
	FIRST_QUARTER,
	WAXING_GIBBOUS,
	FULL_MOON,
	WANING_GIBBOUS,
	LAST_QUARTER,
	WANING_CRESCENT
}

static var current_lunar_phase : LunarPhase = (
	LunarPhase.NEW_MOON
)

@export var enemy_data : EnemyData

var health : int = 0

var is_my_turn : bool = false
var is_busy : bool = false
var is_defending : bool = false

@onready var sprite : Sprite2D = (
	$Sprite2D
)

@onready var health_bar : ProgressBar = (
	$HealthBar
)

@onready var animation_player : AnimationPlayer = (
	$AnimationPlayer
)

func _ready() -> void:

	pass

func setup() -> void:

	if enemy_data == null:

		push_error(
			"EnemyData no asignado"
		)

		return

	_setup_enemy()

	play_idle()

func _setup_enemy() -> void:

	health = enemy_data.max_health

	health_bar.max_value = (
		enemy_data.max_health
	)

	health_bar.value = health

	if enemy_data.sprite != null:

		sprite.texture = (
			enemy_data.sprite
		)

func start_turn() -> void:

	if is_busy:
		return

	is_my_turn = true

	is_defending = false

	print(
		enemy_data.enemy_name +
		" inicia turno"
	)

	print(
		"Fase lunar actual: " +
		str(current_lunar_phase)
	)

	await execute_turn()

	end_turn()

func end_turn() -> void:

	is_my_turn = false

	print(
		enemy_data.enemy_name +
		" termina turno"
	)

func execute_turn() -> void:

	var actions : Array = (
		enemy_data.moon_phase_turns.get(
			current_lunar_phase,
			[]
		)
	)

	if actions.is_empty():

		print(
			enemy_data.enemy_name +
			" no tiene acciones"
		)

		return

	for action_name in actions:

		if is_busy:
			return

		await execute_action(
			str(action_name)
		)

		await get_tree().create_timer(
			0.3
		).timeout

func execute_action(
	action_name : String
) -> void:

	match action_name:

		"ATTACK":
			await action_attack()

		"HEAVY ATTACK":
			await action_heavy_attack()

		"HEAL":
			await action_heal()

		"FULL HEAL":
			await action_full_heal()

		"DEFEND":
			await action_defend()

		"ADVANCE MOON":
			await action_advance_moon()

		"PASS":
			await action_pass()

		_:
			print(
				"Accion desconocida: " +
				action_name
			)

func action_attack() -> void:

	is_busy = true

	print(
		enemy_data.enemy_name +
		" usa ATTACK"
	)

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_heavy_attack() -> void:

	is_busy = true

	print(
		enemy_data.enemy_name +
		" usa HEAVY ATTACK"
	)

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_heal() -> void:

	is_busy = true

	print(
		enemy_data.enemy_name +
		" usa HEAL"
	)

	heal(
		enemy_data.heal_amount
	)

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_full_heal() -> void:

	is_busy = true

	print(
		enemy_data.enemy_name +
		" usa FULL HEAL"
	)

	health = enemy_data.max_health

	update_health_bar()

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_defend() -> void:

	is_busy = true

	is_defending = true

	print(
		enemy_data.enemy_name +
		" usa DEFEND"
	)

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_advance_moon() -> void:

	is_busy = true

	current_lunar_phase += 1

	if current_lunar_phase > (
		LunarPhase.WANING_CRESCENT
	):

		current_lunar_phase = (
			LunarPhase.NEW_MOON
		)

	print(
		enemy_data.enemy_name +
		" adelanta la fase lunar a: " +
		str(current_lunar_phase)
	)

	play_attack()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

func action_pass() -> void:

	is_busy = true

	print(
		enemy_data.enemy_name +
		" pasa turno"
	)

	await get_tree().create_timer(
		0.9
	).timeout

	play_idle()

	is_busy = false

func take_damage(
	amount : int
) -> void:

	if is_busy:
		return

	if is_defending:

		amount *= 0.5

	health -= amount

	if health < 0:
		health = 0

	update_health_bar()

	print(
		enemy_data.enemy_name +
		" recibe " +
		str(amount) +
		" daño"
	)

	is_busy = true

	play_hurt()

	await animation_player.animation_finished

	play_idle()

	is_busy = false

	if health <= 0:
		die()

func heal(
	amount : int
) -> void:

	health += amount

	if health > enemy_data.max_health:

		health = enemy_data.max_health

	update_health_bar()

	print(
		enemy_data.enemy_name +
		" recupera " +
		str(amount)
	)

func update_health_bar() -> void:

	health_bar.value = health

func die() -> void:

	print(
		enemy_data.enemy_name +
		" muere"
	)

	queue_free()

func play_idle() -> void:

	if animation_player.has_animation(
		"idle"
	):

		animation_player.play(
			"idle"
		)

func play_attack() -> void:

	if animation_player.has_animation(
		"attack"
	):

		animation_player.play(
			"attack"
		)

func play_hurt() -> void:

	if animation_player.has_animation(
		"hurt"
	):

		animation_player.play(
			"hurt"
		)
