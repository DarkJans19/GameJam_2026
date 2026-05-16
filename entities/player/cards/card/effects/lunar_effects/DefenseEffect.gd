extends Effect
class_name DefenseEffect

@export var defense_quantity: int

func effect(objetivo: Node):
	if objetivo.has_method("crear_escudo"):
		objetivo.crear_escudo(defense_quantity)
		print("Se aplico", effect_name, "Con escudo: ", defense_quantity)
