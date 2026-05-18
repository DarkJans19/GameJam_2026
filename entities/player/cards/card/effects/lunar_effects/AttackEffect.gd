extends Effect 
class_name AttackEffect

@export var damage_quantity: int

func effect(final_target: Node):
	print("efecto jugado")
	if final_target.has_method("take_damage"):
		final_target.take_damage(damage_quantity)
		print("El objetivo", final_target, "Recibio", damage_quantity)
