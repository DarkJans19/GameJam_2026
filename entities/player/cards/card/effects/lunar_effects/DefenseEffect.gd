extends Effect
class_name DefenseEffect

@export var defense_quantity: int

func effect(health: Node):
	if health.has_method("ganar_armadura"):
		health.ganar_armadura(defense_quantity)
		print("Se aplicó ", effect_name, " con escudo temporal: ", defense_quantity)
