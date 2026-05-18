extends Effect
class_name CoinsEffect

@export var amount_of_coins: int

func effect(game_manager: Node):
	if game_manager.has_method("modificar_oro"):
		game_manager.modificar_oro(amount_of_coins)
		print("Se aplico", effect_name, "Con cantidad de monedas", amount_of_coins)
