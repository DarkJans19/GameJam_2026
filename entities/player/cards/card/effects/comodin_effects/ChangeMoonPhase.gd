extends Effect
class_name ChangeMoonPhase

# @export var lunar_phase_to_change: LunarPhases

func effect(combate: Node):
	if combate.has_method("change_lunar_phase"):
		print("changed to", lunar_phase_to_change)
