extends Resource
class_name CardData 

enum CardType { DAMAGE, HEAL, SHIELD }

@export var card_name: String
@export var sacrifice_cost: int
@export var image: Texture2D
@export_multiline var description: String

# Variables para los efectos
@export var type: CardType
@export var effect_value: int
