extends Effect
class_name StealCards

@export var amount_of_cards_stolen: int
@export var card_type: CardData.CardType

func effect(deck: Node):
	if deck.has_method("draw_card_by_type"):
		print("Carta robada")
		deck.draw_card_by_type(amount_of_cards_stolen, card_type)
		print("The effect was", effect_name, "amount of cards stolen", amount_of_cards_stolen)

func get_dynamic_description() -> String:
	if not effect_description.is_empty():
		return effect_description
		
	var tipo_cartas = " " + card_type_tag if not card_type_tag.is_empty() else ""
	
	# Plantilla: "esta carta robará x cartas + tipoCartas"
	var base_desc = "Esta carta robará %d cartas%s" % [amount_of_cards_stolen, card_type]
	
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
