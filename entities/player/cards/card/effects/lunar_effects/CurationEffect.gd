extends Effect 
class_name CurationEffect

@export var heal_quantity: int

func effect(game_manager: Node):
	if game_manager.has_method("curar_jugador"):
		game_manager.curar_jugador(heal_quantity)
		print("Se aplico", effect_name, "Con curacion: ", heal_quantity)


func get_dynamic_description() -> String:
	# Si se escribió algo a mano, se respeta
	if not effect_description.is_empty():
		return effect_description
		
	# Plantilla: "Esta carta + accion + al jugador"
	var base_desc = "Esta carta curará %d de vida al jugador" % heal_quantity
	
	# Añade la fase si es requerida (usa la función del script padre)
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
