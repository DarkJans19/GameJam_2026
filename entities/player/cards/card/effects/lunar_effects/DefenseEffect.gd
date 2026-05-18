extends Effect
class_name DefenseEffect

@export var defense_quantity: int

func effect(objective: Node):
	if objective.has_method("crear_escudo"):
		objective.crear_escudo(defense_quantity)
		print("Se aplico", effect_name, "Con escudo: ", defense_quantity)
