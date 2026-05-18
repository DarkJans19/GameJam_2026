extends Effect
class_name ChangeMoonPhase

@export var lunar_phase_to_change: CombatManager.LunarPhase

func effect(combate: Node):
	if combate.has_method("change_phase"):
		print("cambiada la fase")
		combate.change_phase(lunar_phase_to_change)
		print("changed to", lunar_phase_to_change)
