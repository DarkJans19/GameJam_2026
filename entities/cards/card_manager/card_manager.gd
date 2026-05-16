extends Node2D

# Constants
const OFFSET_SELECTION = 20

# Variables
var selected_cards = []
var player_hand_reference

@onready var timer = $Timer

func _ready() -> void:
	player_hand_reference = $"../PlayerHand"

func _process(delta: float) -> void:
	pass

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	card.connect("selected", select_card)
	card.connect("show_description", show_description)
	card.connect("hide_description", hide_description)

func on_hovered_over_card(card):
	if card in selected_cards:
		return
		
	high_light_card(card, true)

func on_hovered_off_card(card):
	if card in selected_cards:
		return
		
	high_light_card(card, false)

func high_light_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1	


func high_light_selected_cards(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.position.y -= OFFSET_SELECTION
		card.z_index = 3
	else:
		card.scale = Vector2(1, 1)
		card.position.y += OFFSET_SELECTION
		card.z_index = 1	


func select_card(card):
	if card in selected_cards:
		selected_cards.erase(card)
		high_light_selected_cards(card, false)
	else:
		selected_cards.append(card)
		high_light_selected_cards(card, true)


func show_description(card):
	card.description.text = card.card_data.description
	card.description.show() 

# Limpia y oculta la descripción al salir el mouse
func hide_description(card):
	card.description.text = ""
	card.description.hide()
	
