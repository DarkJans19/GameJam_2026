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

@export var effects: Array[Effect]

func make_action(objective: Node) ->void:
	print("The card", card_name, "was played and his cost was", sacrifice_cost, 
	"his type is ", type, "and his value is: ", effect_value)
