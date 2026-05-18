extends Node2D

const CARD_SCENE = preload("res://entities/player/cards/card/card.tscn")

@onready var card_manager = $"../CardManager"
@onready var player_hand = $"../PlayerHand"

var normal_cards: Array[String] = []
var lunar_cards: Array[String] = []
var comodin_cards: Array[String] = []

func preparate_initial_hand() -> void:
	var mazo = get_tree().get_first_node_in_group("deck")
	if mazo and mazo.has_method("preparate_initial_hand"):
		mazo.preparate_initial_hand()
		
	normal_cards.clear()
	lunar_cards.clear()
	comodin_cards.clear()
	
	for card_path in game_manager.mazo_jugador:
		if not ResourceLoader.exists(card_path):
			push_error("No se pudo encontrar el recurso de la carta en: " + card_path)
			continue
			
		var resource = load(card_path)
		if resource is CardData:
			match resource.type:
				CardData.CardType.NORMAL:
					normal_cards.append(card_path)
				CardData.CardType.LUNAR:
					lunar_cards.append(card_path)
				CardData.CardType.COMODIN:
					comodin_cards.append(card_path)
					
	normal_cards.shuffle()
	lunar_cards.shuffle()
	comodin_cards.shuffle()

func draw_card_by_type(amount: int, type: CardData.CardType) -> void:
	match type:
		CardData.CardType.NORMAL:
			draw_card(amount, normal_cards)
		CardData.CardType.LUNAR:
			draw_card(amount, lunar_cards)
		CardData.CardType.COMODIN:
			draw_card(amount, comodin_cards)

func draw_card(amount_cards_to_drawn: int, deck: Array) -> void:
	for i in range(amount_cards_to_drawn):
		if deck.is_empty():
			break

		var card_path = deck.pop_front()
		var resource = load(card_path)

		if resource == null:
			push_error("No se pudo cargar la carta: " + card_path)
			continue

		var new_card = CARD_SCENE.instantiate()
		new_card.card_data = resource

		if player_hand.has_method("add_card_to_hand"):
			player_hand.add_card_to_hand(new_card)
			card_manager.call_deferred("add_child", new_card)
