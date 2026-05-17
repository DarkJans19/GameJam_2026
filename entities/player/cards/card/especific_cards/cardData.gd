extends Resource
class_name CardData 

enum CardTypeAction { DAMAGE, HEAL, SHIELD }
enum CardType {COMODIN, NORMAL, LUNAR}
enum TargetType {
	NONE,
	SINGLE_ENEMY,
	ALL_ENEMIES,
	PLAYER,
	DECK
}

@export var card_name: String
@export var sacrifice_cost: int
@export var image: Texture2D
@export_multiline var description: String

# Variables para los efectos
@export var card_type_action: CardTypeAction
@export var effect_value: int
@export var type: CardType
@export var target_type: TargetType

@export var effects: Array[Effect]

func apply_effect(clicked_target: Node, tree: SceneTree) -> void:
	match target_type:
		TargetType.SINGLE_ENEMY:
			if clicked_target and clicked_target.is_in_group("Enemies"):
				efecto(clicked_target)
				
		TargetType.PLAYER:
			var player = tree.get_first_node_in_group("Player")
			if player:
				efecto(player)
				
		TargetType.DECK:
			var deck = tree.get_first_node_in_group("DeckManager")
			if deck:
				efecto(deck)


func efecto(final_target: Node) -> void:
	pass
