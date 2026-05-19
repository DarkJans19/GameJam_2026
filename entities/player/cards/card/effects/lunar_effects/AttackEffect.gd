extends Effect 
class_name AttackEffect

@export var damage_quantity: int

func effect(final_target: Node):
	if final_target.has_method("take_damage"):
		final_target.take_damage(damage_quantity)
		print("El objetivo", final_target, "Recibio", damage_quantity)

func get_dynamic_description() -> String:
	if not effect_description.is_empty():
		return effect_description
		
	# Evaluamos el tipo de distribución según el target_type heredado
	var tipo_distribucion = "individual"
	if target_type == TargetType.ALL_ENEMIES:
		tipo_distribucion = "en grupo"
	elif target_type == TargetType.RANDOM_ENEMIES:
		tipo_distribucion = "a %d enemigo(s) aleatorio(s)" % random_targets_count
		
	# Plantilla: "Esta carta infligirá + xcantidaddeDaño + engrupo/individual"
	var base_desc = "Esta carta infligirá %d de daño %s" % [damage_quantity, tipo_distribucion]
	
	if requires_specific_phase:
		base_desc += " [Solo en %s]" % _get_phase_name_es(required_lunar_phase)
		
	return base_desc + "."
