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

func effect(final_target: Node) -> void:
	pass
