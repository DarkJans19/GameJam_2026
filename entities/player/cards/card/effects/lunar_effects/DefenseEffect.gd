extends Effect
class_name DefenseEffect

@export var defense_quantity: int

func effect(health: Node):
	if health.has_method("ganar_armadura"):
		health.ganar_armadura(defense_quantity)
		print("Se aplicó ", effect_name, " con escudo temporal: ", defense_quantity)

func get_dynamic_description() -> String:
	# Si se escribió algo a mano, se respeta
	if not effect_description.is_empty():
		return effect_description
		
	# Plantilla: "Esta carta + accion + al jugador"
	var base_desc = "Esta carta dará %d de escudo al jugador" % defense_quantity
	
	# Añade la fase si es requerida (usa la función del script padre)
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
