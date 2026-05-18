extends Resource
class_name Effect

enum TargetType {
	NONE,
	SINGLE_ENEMY,
	ALL_ENEMIES,
	RANDOM_ENEMIES,
	PLAYER,
	COMBAT,
	DECK,
	GAME_MANAGER,
	HEALTH,
}

@export var effect_name: String
@export_multiline var effect_description: String
@export var target_type: TargetType
@export var random_targets_count: int = 1

# Requests
@export var required_lunar_phase: CombatManager.LunarPhase = CombatManager.LunarPhase.NEW_MOON
@export var requires_specific_phase: bool = false 


func apply_effect(clicked_target: Node, tree: SceneTree) -> void:
	if requires_specific_phase:
			var combat = tree.get_first_node_in_group("CombatManager")
			if combat and required_lunar_phase != combat.lunar_phase:
				print("Efecto '", effect_name, "' bloqueado: fase incorrecta.")
				return
			
	match target_type:
		TargetType.SINGLE_ENEMY:
			if clicked_target and clicked_target.is_in_group("enemies"):
				effect(clicked_target)
				
		TargetType.ALL_ENEMIES:
			var all_enemies = tree.get_nodes_in_group("enemies")
			for enemy in all_enemies:
				effect(enemy)
				
		TargetType.RANDOM_ENEMIES:
			var all_enemies = tree.get_nodes_in_group("enemies")
			all_enemies.shuffle() 
			var targets_to_hit = min(random_targets_count, all_enemies.size())
			for i in range(targets_to_hit):
				effect(all_enemies[i])
				
		TargetType.PLAYER:
			var player = tree.get_first_node_in_group("player")
			if player:
				effect(player)
		
		TargetType.DECK:
			var deck = tree.get_first_node_in_group("deck")
			if deck:
				effect(deck)
				
		TargetType.COMBAT:
			var combat = tree.get_first_node_in_group("CombatManager")
			if combat:
				effect(combat)
			else:
				push_error("No se pudo aplicar el efecto: CombatManager no encontrado en el grupo.")
		TargetType.GAME_MANAGER:
			var game_manager = tree.get_first_node_in_group("game_manager")
			if game_manager:
				effect(game_manager)
			else:
				push_error("No se pudo aplicar el efecto: health no encontrado en el grupo.")
		TargetType.HEALTH:
			var health = tree.get_first_node_in_group("health")
			if health:
				effect(health)
			else:
				push_error("No se pudo aplicar el efecto: health no encontrado en el grupo.")


func effect(objective: Node) -> void:
	pass
