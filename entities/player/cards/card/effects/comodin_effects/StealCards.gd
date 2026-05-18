extends Effect
class_name StealCards

@export var amount_of_cards_stolen: int
@export var card_type: CardData.CardType

func effect(deck: Node):
	if deck.has_method("draw_card"):
		deck.draw_card_by_type(amount_of_cards_stolen, card_type)
		print("The effect was", effect_name, "amount of cards stolen", amount_of_cards_stolen)
