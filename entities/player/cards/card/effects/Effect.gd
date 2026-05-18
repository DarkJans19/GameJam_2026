extends Resource
class_name Effect

enum TargetType {
	NONE,
	SINGLE_ENEMY,
	ALL_ENEMIES,
	RANDOM_ENEMIES,
	COMBAT,
	DECK,
	GAME_MANAGER,
	HEALTH,
}

@export var effect_name: String
@export_multiline var effect_description: String
@export var target_type: TargetType
@export var random_targets_count: int = 1

# --- NUEVAS VARIABLES PARA AUTOMATIZAR EL TEXTO DEFAULT ---
@export var effect_value: int = 0
@export var card_type_tag: String = ""

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

# --- SISTEMA DE PLANTILLAS DINÁMICAS ---
func get_dynamic_description() -> String:
	# Si ya escribiste una descripción manual en el Inspector, la respetamos
	if not effect_description.is_empty():
		return effect_description
		
	var base_desc = ""
	
	match target_type:
		# 1. CASO DAÑO: Enemigo Único, Todos o Aleatorios
		TargetType.SINGLE_ENEMY, TargetType.ALL_ENEMIES, TargetType.RANDOM_ENEMIES:
			var tipo_distribucion = "individual"
			if target_type == TargetType.ALL_ENEMIES:
				tipo_distribucion = "en grupo"
			elif target_type == TargetType.RANDOM_ENEMIES:
				tipo_distribucion = "a %d enemigo(s) aleatorio(s)" % random_targets_count
				
			base_desc = "Esta carta infligirá %d de daño %s" % [effect_value, tipo_distribucion]
			
		# 2. CASO ROBO: Interacción con el Deck
		TargetType.DECK:
			var tipo_cartas = " " + card_type_tag if not card_type_tag.is_empty() else ""
			base_desc = "Esta carta robará %d cartas%s" % [effect_value, tipo_cartas]
			
		# 3. CASO JUGADOR: Modificaciones de salud o estados del GameManager
		TargetType.GAME_MANAGER, TargetType.HEALTH:
			# Aquí 'effect_name' actuará como la acción (ej: "otorgará 10 de escudo")
			var accion = effect_name if not effect_name.is_empty() else "aplicará una alteración"
			base_desc = "Esta carta %s al jugador" % accion
			
		# Cualquier otro caso base o vacío
		_:
			if not effect_name.is_empty():
				base_desc = effect_name
			else:
				base_desc = "Aplica un efecto general."

	# Limpiamos espacios y añadimos el punto final
	base_desc = base_desc.strip_edges() + "."
	
	# Si requiere una fase específica, añadimos la aclaración automáticamente
	if requires_specific_phase:
		var phase_str = _get_phase_name_es(required_lunar_phase)
		base_desc += " [Solo en %s]" % phase_str
		
	return base_desc

# Función auxiliar para traducir el Enum de fases a texto legible en español
func _get_phase_name_es(phase: int) -> String:
	match phase:
		0: return "Luna Nueva"          # NEW_MOON
		1: return "Cuarto Menguante"    # WANING_CRESCENT
		2: return "Último Cuarto"       # LAST_QUARTER
		3: return "Gibosa Menguante"    # WANING_GIBBOUS
		4: return "Luna Llena"          # FULL_MOON
		5: return "Gibosa Creciente"    # WAXING_GIBBOUS
		6: return "Primer Cuarto"       # FIRST_QUARTER
		7: return "Cuarto Creciente"    # WAXING_CRESCENT
	return "Fase Desconocida"

func effect(objective: Node) -> void:
	pass
