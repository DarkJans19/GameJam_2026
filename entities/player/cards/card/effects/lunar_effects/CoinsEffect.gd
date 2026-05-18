extends Effect
class_name CoinsEffect

@export var amount_of_coins: int

func effect(player: Node):
	if player.has_method("get_coins"):
		print("robo_monedas")
		player.get_coins(amount_of_coins)
		print("Se aplico", effect_name, "Con cantidad de monedas", amount_of_coins)
