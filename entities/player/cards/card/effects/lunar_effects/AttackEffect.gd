extends Effect 
class_name AttackEffect

@export var damage_quantity: int

func effect(objetivo: Node):
	if objetivo.has_method("recibir_daño"):
		objetivo.recibir_daño(damage_quantity)
		print("Se aplico", effect_name, "Con daño", damage_quantity)
