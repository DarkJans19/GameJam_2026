extends Resource
class_name Effect

enum LunarPhases { QUARTER_MOON, HALF_MOON, THREE_QUARTER_MOON, FULL_MOON, NO_MOON, NO_LUNAR_PHASE}

@export var effect_name: String
@export_multiline var effect_description: String
@export var lunar_phase: LunarPhases


func effect(objetivo: Node) -> void:
	pass
