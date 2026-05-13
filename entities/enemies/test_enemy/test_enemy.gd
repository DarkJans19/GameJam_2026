extends Enemy

func _ready():

	enemy_name = "Test Enemy"
	max_health = 150
	actions_per_turn = 3

	super._ready()

func _process(delta):

	if is_busy:
		return

	if Input.is_action_just_pressed("attack"):
		await play_attack_test()

	if Input.is_action_just_pressed("hurt"):
		await hurt_test()

	if Input.is_action_just_pressed("heal"):
		await heal_test()

	if Input.is_action_just_pressed("reset"):
		set_turn(1)

func select_basic_action() -> String:

	if health <= max_health * 0.3:

		var heal_probability = randi_range(1, 100)

		if heal_probability <= 70:
			return "heal"

	return "attack"

func basic_attack():

	is_busy = true

	print(enemy_name + " realiza attack")

	play_attack()

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

func basic_heal():

	is_busy = true

	print(enemy_name + " realiza heal")

	play_hurt()

	heal(15)

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

func play_attack_test():

	is_busy = true

	play_attack()

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false

func hurt_test():

	take_damage(10)

func heal_test():

	is_busy = true

	play_hurt()

	heal(10)

	await get_tree().create_timer(1.0).timeout

	play_idle()

	is_busy = false
