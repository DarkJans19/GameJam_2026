extends Enemy

func _ready():
	enemy_name = "Test Enemy"
	max_health = 150
	actions_per_turn = 3
	super._ready()

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		await play_attack_test()
	if Input.is_action_just_pressed("hurt"):
		await play_hurt_test()
		take_damage(10)
	if Input.is_action_just_pressed("heal"):
		heal(10)
	if Input.is_action_just_pressed("reset"):
		set_turn(1)

func select_basic_action() -> String:
	if health <= max_health * 0.3:
		var heal_probability = randi_range(1, 100)
		if heal_probability <= 70:
			return "heal"
	return "attack"

func basic_attack():
	print(enemy_name + " realiza attack")
	play_attack()
	await get_tree().create_timer(1.0).timeout
	play_idle()

func basic_heal():
	print(enemy_name + " realiza HEAL")
	play_hurt()
	heal(15)
	await get_tree().create_timer(1.0).timeout
	play_idle()

func play_attack_test():
	play_attack()
	await get_tree().create_timer(1.0).timeout
	play_idle()

func play_hurt_test():
	play_hurt()
	await get_tree().create_timer(1.0).timeout
	play_idle()
