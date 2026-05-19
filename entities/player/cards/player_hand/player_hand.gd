extends Node2D

const CARD_WIDTH = 22  
const HAND_Y_POSITION = 75

var player_hand = []

func _ready() -> void:
	position = Vector2(0, 0)

func add_card_to_hand(new_card):
	player_hand.insert(0, new_card)
	update_hand_position()
	
func update_hand_position():
	for i in range(player_hand.size()):
		var card = player_hand[i]
		var current_y = card.position.y if card.position.y != 0 else HAND_Y_POSITION
		
		if not card in get_node("../CardManager").selected_cards:
			current_y = HAND_Y_POSITION
			card.scale = get_node("../CardManager").BASE_SCALE
			card.z_index = 10 + i
			
		var new_position = Vector2(calculate_new_card_position(i), current_y)
		animate_card_to_position(card, new_position)

func calculate_new_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH 
	var x_offset = (index * CARD_WIDTH) - (total_width / 2)
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_cards_of_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
