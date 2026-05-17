extends Resource
class_name Effect

enum LunarPhases { QUARTER_MOON, HALF_MOON, THREE_QUARTER_MOON, FULL_MOON, NO_MOON, NO_LUNAR_PHASE}

@export var effect_name: String
@export_multiline var effect_description: String
@export var lunar_phase: LunarPhases

enum TargetType {
	NONE,               # No necesita objetivo (ej. Ganar monedas)
	SINGLE_ENEMY,       # El enemigo que el jugador seleccionó
	ALL_ENEMIES,        # Todos los enemigos en pantalla
	PLAYER,             # El jugador (ej. Curar, dar escudo)
	DECK                # El gestor de cartas (ej. Robar cartas)
}

@export var target_type: TargetType
func effect(objetivo: Node) -> void:
	pass
