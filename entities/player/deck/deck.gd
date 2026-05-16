extends Node2D

const CARD_SCENE_PATH = "res://entities/player/cards/card/card.tscn"

@export var player_deck = ["res://entities/player/cards/card/especific_cards/caballo_bandera.tres", "res://entities/cards/card/especific_cards/cabeza_alien.tres", "res://entities/cards/card/especific_cards/doble_alien.tres", "res://entities/cards/card/especific_cards/guantes.tres", "res://entities/cards/card/especific_cards/jimbo.tres", "res://entities/cards/card/especific_cards/joaquin.tres", "res://entities/cards/card/especific_cards/lobo_fantasma.tres", "res://entities/cards/card/especific_cards/mosquito_magico.tres", "res://entities/cards/card/especific_cards/naranja_medieval.tres"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_scene = preload(CARD_SCENE_PATH)
	
	player_deck.shuffle()
	
	for i in range(player_deck.size()):
		var resource = load(player_deck[i])
		
		var new_card = card_scene.instantiate()
		
		new_card.card_data = resource
		
		$"../CardManager".add_child(new_card)
		$"../PlayerHand".add_card_to_hand(new_card)


func draw_card():
	print(player_deck)
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
