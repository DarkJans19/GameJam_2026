extends Resource
class_name Effect

enum TargetType {
	NONE,
	SINGLE_ENEMY,
	ALL_ENEMIES,
	RANDOM_ENEMIES,
	PLAYER,
	DECK
}

@export var effect_name: String
@export_multiline var effect_description: String
@export var target_type: TargetType

@export var random_targets_count: int = 1

func apply_effect(clicked_target: Node, tree: SceneTree) -> void:
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

func effect(objective: Node) -> void:
	pass
