# attack_effect.gd
extends Effect
class_name CoinsEffect

@export var amount_of_coins: int

func effect(objetivo: Node):
	if objetivo.has_method("get_coins"):
		objetivo.get_coins(amount_of_coins)
		print("Se aplico", effect_name, "Con cantidad de monedas", amount_of_coins)
