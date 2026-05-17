extends Node2D

const CARD_SCENE = preload("res://entities/player/cards/card/card.tscn")

@onready var card_manager = $"../CardManager"
@onready var player_hand = $"../PlayerHand"

@export var lunar_cards_resources: Array[String] = [
	"res://entities/player/cards/card/especific_cards/caballo_bandera.tres",
	"res://entities/player/cards/card/especific_cards/cabeza_alien.tres",
	"res://entities/player/cards/card/especific_cards/doble_alien.tres",
	"res://entities/player/cards/card/especific_cards/guantes.tres",
	"res://entities/player/cards/card/especific_cards/jimbo.tres",
	"res://entities/player/cards/card/especific_cards/joaquin.tres",
	"res://entities/player/cards/card/especific_cards/lobo_fantasma.tres",
	"res://entities/player/cards/card/especific_cards/mosquito_magico.tres",
	"res://entities/player/cards/card/especific_cards/naranja_medieval.tres",
	"res://entities/player/cards/card/especific_cards/ratastronauta.tres",
]

@export var normal_cards_resources: Array[String] = []
@export var comodin_cards_resources: Array[String] = []

const INITIAL_NORMAL_CARDS = 5
const INITIAL_LUNAR_CARDS = 10
const INITIAL_COMODIN_CARDS = 0

var player_deck = []
var game_deck = []

var lunar_cards: Array[String] = []
var normal_cards: Array[String] = []
var comodin_cards: Array[String] = []


func _ready() -> void:
	lunar_cards = initialize_deck(INITIAL_LUNAR_CARDS, lunar_cards_resources)
	normal_cards = initialize_deck(INITIAL_NORMAL_CARDS, normal_cards_resources)
	comodin_cards = initialize_deck(INITIAL_COMODIN_CARDS, comodin_cards_resources)

	draw_card(INITIAL_NORMAL_CARDS, normal_cards)
	draw_card(INITIAL_LUNAR_CARDS, lunar_cards)
	draw_card(INITIAL_COMODIN_CARDS, comodin_cards)


func initialize_deck(amount_cards_of_deck: int, available_resources: Array) -> Array:
	var new_deck: Array[String] = []

	if available_resources.is_empty():
		return new_deck

	for i in range(amount_cards_of_deck):
		new_deck.append(available_resources.pick_random())

	return new_deck


func draw_card(amount_cards_to_drawn: int, deck: Array) -> void:
	for i in range(amount_cards_to_drawn):

		if deck.is_empty():
			print("No quedan más cartas en este mazo.")
			break

		var card_path = deck.pop_front()
		var resource = load(card_path)

		if resource == null:
			push_error("No se pudo cargar la carta: " + card_path)
			continue

		var new_card = CARD_SCENE.instantiate()
		new_card.card_data = resource

		if player_hand.has_method("add_card_to_hand"):
			player_hand.add_child(new_card)
			player_hand.add_card_to_hand(new_card)

		player_deck.append(new_card)


func draw_card_by_type(amount: int, card_type: CardData.CardType) -> void:
	match card_type:
		CardData.CardType.COMODIN:
			draw_card(amount, comodin_cards)

		CardData.CardType.NORMAL:
			draw_card(amount, normal_cards)

		CardData.CardType.LUNAR:
			draw_card(amount, lunar_cards)
