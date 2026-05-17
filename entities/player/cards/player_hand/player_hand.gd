extends Node2D

const CARD_WIDTH = 50

const HAND_Y_POSITION = 150
const X_LENGHT = 320

var player_hand = []
var center_screen_x = 320

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = X_LENGHT / 2

func add_card_to_hand(new_card):
	player_hand.insert(0, new_card)
	new_card.scale = Vector2(0.3, 0.3)
	update_hand_position()
	
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_new_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		animate_card_to_position(card, new_position)
	

func calculate_new_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH 
	var x_offset = center_screen_x + (index * CARD_WIDTH) - (total_width / 2)
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
	pass


func remove_cards_of_hand(card):
	print(player_hand)
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
