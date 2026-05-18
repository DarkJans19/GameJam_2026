extends Node2D

const CARD_SCENE = preload("res://entities/player/cards/card/card.tscn")

@onready var card_manager = $"../CardManager"
@onready var player_hand = $"../PlayerHand"

var normal_cards: Array[String] = []
var lunar_cards: Array[String] = []
var comodin_cards: Array[String] = []

var normal_deck: Array[String] = []
var lunar_deck: Array[String] = []
var comodin_deck: Array[String] = []

func _ready() -> void:
	add_to_group("deck")

func preparate_initial_hand() -> void:
	normal_cards.clear()
	lunar_cards.clear()
	comodin_cards.clear()

	for card_path in game_manager.mazo_jugador:
		if not ResourceLoader.exists(card_path):
			push_error("No se pudo encontrar el recurso: " + card_path)
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

	normal_deck = normal_cards.duplicate()
	lunar_deck = lunar_cards.duplicate()
	comodin_deck = comodin_cards.duplicate()

	normal_deck.shuffle()
	lunar_deck.shuffle()
	comodin_deck.shuffle()

func draw_card_by_type(amount: int, type: CardData.CardType) -> void:
	match type:
		CardData.CardType.NORMAL:
			draw_card(amount, normal_deck)

		CardData.CardType.LUNAR:
			draw_card(amount, lunar_deck)

		CardData.CardType.COMODIN:
			draw_card(amount, comodin_deck)

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

		card_manager.add_child(new_card)

		if player_hand.has_method("add_card_to_hand"):
			player_hand.add_card_to_hand(new_card)
