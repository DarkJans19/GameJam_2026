extends Node2D

var selected = false
var selected_cards = []
var index = 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	card.connect("selected", select_card)


func on_hovered_over_card(card):
	high_light_card(card, true)


func on_hovered_off_card(card):
	high_light_card(card, false)


func high_light_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
		

func high_light_selected_cards(card, status):
	if status:
		card.scale = Vector2(1.15, 1.15)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1	
	


func select_card(card):
	if card not in selected_cards:
		high_light_selected_cards(card, true)
		selected_cards.erase(card)
	else:
		selected_cards.append(card)
		high_light_selected_cards(card, false)
	print(selected_cards)
