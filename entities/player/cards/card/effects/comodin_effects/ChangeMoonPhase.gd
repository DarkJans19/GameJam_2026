extends Effect
class_name ChangeMoonPhase

@export var lunar_phase_to_change: CombatManager.LunarPhase

func effect(combate: Node):
	if combate.has_method("change_phase"):
		combate.change_phase(lunar_phase_to_change)

func get_dynamic_description() -> String:
	# Si se escribió algo a mano, se respeta
	if not effect_description.is_empty():
		return effect_description
		
	# Plantilla: "Esta carta + accion + al jugador"
	var base_desc = "Esta carta cambiara a la fase %d" % lunar_phase_to_change
	
	# Añade la fase si es requerida (usa la función del script padre)
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
