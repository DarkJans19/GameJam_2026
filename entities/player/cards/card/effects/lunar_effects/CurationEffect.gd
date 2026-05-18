extends Effect 
class_name CurationEffect

@export var heal_quantity: int

func effect(objective: Node):
	if objective.has_method("heal"):
		objective.heal(heal_quantity)
		print("Se aplico", effect_name, "Con curacion: ", heal_quantity)
