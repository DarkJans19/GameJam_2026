extends Effect
class_name CoinsEffect

@export var amount_of_coins: int

func effect(game_manager: Node):
	if game_manager.has_method("modificar_oro"):
		game_manager.modificar_oro(amount_of_coins)
		print("Se aplico", effect_name, "Con cantidad de monedas", amount_of_coins)

func get_dynamic_description() -> String:
	# Si se escribió algo a mano, se respeta
	if not effect_description.is_empty():
		return effect_description
		
	# Plantilla: "Esta carta + accion + al jugador"
	var base_desc = "Esta carta dará %d de monedas al jugador" % amount_of_coins
	
	# Añade la fase si es requerida (usa la función del script padre)
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
