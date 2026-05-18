extends Resource
class_name CardData 

enum CardTypeAction { DAMAGE, HEAL, SHIELD }
enum CardType {COMODIN, NORMAL, LUNAR}

@export var card_name: String
@export var sacrifice_cost: int
@export var image: Texture2D
@export_multiline var description: String

# Variables para los efectos
@export var card_type_action: CardTypeAction
@export var effect_value: int
@export var type: CardType


@export var required_lunar_phase: CombatManager.LunarPhase = CombatManager.LunarPhase.NEW_MOON
@export var requires_specific_phase: bool = false 

@export var effects: Array[Effect]

func effect(final_target: Node) -> void:
	pass
