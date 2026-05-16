extends Effect
class_name ChangeMoonPhase

@export var lunar_phase_to_change: LunarPhases

func effect(objetivo: Node):
	if objetivo.has_method("change_lunar_phase"):
		print("changed to", lunar_phase_to_change)
