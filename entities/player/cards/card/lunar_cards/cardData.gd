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

func get_full_description() -> String:
	var dynamic_lines: Array[String] = []

	# 2. Auto-generar texto si es una carta NORMAL con valores de acción directa
	if type == CardType.NORMAL and effect_value > 0:
		match card_type_action:
			CardTypeAction.DAMAGE:
				dynamic_lines.append("Inflige %d de daño al enemigo seleccionado." % effect_value)
			CardTypeAction.HEAL:
				dynamic_lines.append("Cura %d de vida al jugador." % effect_value)
			CardTypeAction.SHIELD:
				dynamic_lines.append("Otorga %d de escudo al jugador." % effect_value)

	for effect in effects:
		if effect and effect.has_method("get_dynamic_description"):
			dynamic_lines.append(effect.get_dynamic_description())

	if dynamic_lines.is_empty():
		return "Sin descripción disponible."

	return "\n".join(dynamic_lines)

func effect(final_target: Node) -> void:
	pass
