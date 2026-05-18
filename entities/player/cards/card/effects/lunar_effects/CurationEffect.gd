extends Effect 
class_name CurationEffect

@export var heal_quantity: int

func effect(game_manager: Node):
	if game_manager.has_method("curar_jugador"):
		game_manager.curar_jugador(heal_quantity)
		print("Se aplico", effect_name, "Con curacion: ", heal_quantity)
