extends Effect
class_name SkipTurnEffect

func effect(objective: Node) -> void:
	if objective is CombatManager:
		objective.skip_next_enemy_turn = true
		print("[Efecto] Se ha programado el salto del próximo turno enemigo.")
