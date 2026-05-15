extends Node2D

const CARD_SCENE_PATH = "res://entities/cards/card/card.tscn"
var card_database_reference
var player_deck = ["Card", "Card"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_scene = preload(CARD_SCENE_PATH)
	var card_database = preload("res://entities/cards/cardDatabase/cardDatabase.gd")
	
	player_deck.shuffle()
	
	for i in range(player_deck.size()):
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		$"../PlayerHand".add_card_to_hand(new_card)


func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
