extends Node2D
class_name CombatManager

signal jugador_selecciona_enemigo
signal ataque_iniciado

enum StageType { EARLY, MID, LATE, BOSS }
enum TurnState { START_BATTLE, FINISH_BATTLE, PLAYER_TURN, ENEMY_TURN }
enum LunarPhase { NEW_MOON, WAXING_CRESCENT, FIRST_QUARTER, WAXING_GIbBOUS, FULL_MOON, WANING_GIbBOUS, LAST_QUARTER, WANING_CRESCENT }

var lunar_phase = LunarPhase.NEW_MOON
var actual_turn: TurnState = TurnState.START_BATTLE

const BATLASER = preload("res://entities/enemy/especific_enemies/batlaser.tres")
const BEE = preload("res://entities/enemy/especific_enemies/bee.tres")
const CAT_ALIEN = preload("res://entities/enemy/especific_enemies/cat_alien.tres")
const CARISTAN = preload("res://entities/enemy/especific_enemies/caristan.tres")
const HEZEQUIAH = preload("res://entities/enemy/especific_enemies/hezequiah.tres")

@export var current_stage : StageType = StageType.EARLY

var turno_jugador : bool = true
var puede_abrir_menu : bool = true
var personaje_seleccionado
var personaje_objetivo
var enemigos : Array = []
var jugadores : Array = []
var turno_enemigo : int = 0
var current_selected_enemy : Enemy = null
var cantidad_inicial_enemigos : int = 0

@onready var midground : Node2D = $Midground
@onready var enemy_container : Node2D = $EnemyContainer
@onready var enemy_spawn_1 : Marker2D = $Midground/EnemySpawn1
@onready var enemy_spawn_2 : Marker2D = $Midground/EnemySpawn2
@onready var enemy_spawn_3 : Marker2D = $Midground/EnemySpawn3
@onready var attack_button = $Attack
@onready var sacrifice_button = $Sacrifice
@onready var deck_node: Node2D = $Deck
@onready var player_hand: Node2D = $PlayerHand
@onready var card_manager: Node2D = $CardManager

var enemy_scene : PackedScene = preload("res://entities/enemy/enemy.tscn")

var early_formations : Array = [
	{"weight": 50, "enemies": [BATLASER]},
	{"weight": 35, "enemies": [BATLASER, BEE]},
	{"weight": 15, "enemies": [BEE, BEE, BATLASER]}
]
var mid_formations : Array = [
	{"weight": 50, "enemies": [CAT_ALIEN, BEE]},
	{"weight": 50, "enemies": [BEE, BATLASER]}
]
var late_formations : Array = []
var boss_formations : Array = [
	{"weight": 90, "enemies": [CARISTAN]},
	{"weight": 10, "enemies": [HEZEQUIAH]}
]

func _ready() -> void:
	randomize()
	if "etapa_combate_actual" in game_manager:
		current_stage = game_manager.etapa_combate_actual as StageType
		print("[CombatManager] Iniciando combate en la etapa: ", StageType.keys()[current_stage])
	spawn_enemy_formation()
	await get_tree().process_frame
	enemigos = get_tree().get_nodes_in_group("enemies")
	cantidad_inicial_enemigos = enemigos.size()
	jugadores = get_tree().get_nodes_in_group("player")
	# Pruebas
	"""
	var mazo = get_tree().get_first_node_in_group("deck")
	if mazo and mazo.has_method("preparate_initial_hand"):
		mazo.preparate_initial_hand()
	"""
	start_battle()

func get_stage_formations() -> Array:
	match current_stage:
		StageType.EARLY: return early_formations
		StageType.MID: return mid_formations
		StageType.LATE: return late_formations
		StageType.BOSS: return boss_formations
	return []

func get_random_formation() -> Dictionary:
	var formations : Array = get_stage_formations()
	var total_weight : int = 0
	for formation in formations:
		total_weight += formation["weight"]
	var rng : int = randi_range(1, total_weight)
	var accumulated : int = 0
	for formation in formations:
		accumulated += formation["weight"]
		if rng <= accumulated:
			return formation
	return {}

func spawn_enemy_formation() -> void:
	var formation : Dictionary = get_random_formation()
	if formation.is_empty():
		push_error("No se encontro formacion")
		return
	var enemies_data : Array = formation["enemies"]
	var spawns : Array[Marker2D] = [enemy_spawn_1, enemy_spawn_2, enemy_spawn_3]

	for i in enemies_data.size():
		if i >= spawns.size(): break
		var enemy_instance : Enemy = enemy_scene.instantiate()
		enemy_container.add_child(enemy_instance)
		enemy_instance.global_position = spawns[i].global_position
		enemy_instance.z_index = 10
		enemy_instance.scale = Vector2(0.8, 0.8)
		enemy_instance.enemy_data = enemies_data[i]
		enemy_instance.setup()
		if not enemy_instance.is_connected("selected", _on_enemy_selected):
			enemy_instance.connect("selected", _on_enemy_selected)

func start_battle():
	actual_turn = TurnState.START_BATTLE
	if deck_node and deck_node.has_method("preparate_initial_hand"):
		deck_node.preparate_initial_hand()
	start_player_turn()

func start_player_turn():
	actual_turn = TurnState.PLAYER_TURN
	if deck_node and deck_node.has_method("draw_card_by_type"):
		deck_node.draw_card_by_type(2, CardData.CardType.NORMAL)
		deck_node.draw_card_by_type(2, CardData.CardType.COMODIN)
		deck_node.draw_card_by_type(2, CardData.CardType.LUNAR)

func start_enemy_turn():
	actual_turn = TurnState.ENEMY_TURN
	print("--- Enemies turn ---")
	enemigos = get_tree().get_nodes_in_group("enemies")
	
	var alguno_vivo = false
	for enemy in enemigos:
		if is_instance_valid(enemy) and enemy.health > 0:
			alguno_vivo = true
			await enemy.start_turn()
			await get_tree().create_timer(0.5).timeout 
	
	if not alguno_vivo:
		verificar_estado_batalla()
		return
		
	avanzar_fase_del_juego()
	start_player_turn()

func verificar_estado_batalla() -> void:
	var enemigos_vivos = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy.health > 0:
			enemigos_vivos = true
			break
			
	if not enemigos_vivos:
		actual_turn = TurnState.FINISH_BATTLE
		print("[CombatManager] Todos los enemigos derrotados.")
		game_manager.procesar_victoria_combate(cantidad_inicial_enemigos)
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://stages/map/map.tscn")

func _on_enemy_selected(new_enemy: Enemy) -> void:
	if current_selected_enemy == new_enemy: return
	if current_selected_enemy != null and is_instance_valid(current_selected_enemy):
		current_selected_enemy.set_selected(false)
	current_selected_enemy = new_enemy
	current_selected_enemy.set_selected(true)
	establecer_objetivo(new_enemy)

func get_current_target() -> Enemy:
	if is_instance_valid(current_selected_enemy): return current_selected_enemy
	return null

func mostrar_seleccion() -> void:
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")

func establecer_personaje(personaje) -> void: personaje_seleccionado = personaje
func establecer_objetivo(personaje) -> void: personaje_objetivo = personaje
func iniciar_ataque() -> void:
	emit_signal("ataque_iniciado")
	personaje_seleccionado.atacar_personaje(personaje_objetivo)

func avanzar_fase_del_juego() -> void:
	lunar_phase = (lunar_phase + 1) % 8 as LunarPhase
	print("La nueva fase del juego es la número: ", lunar_phase)

func change_phase(fase: LunarPhase) -> void:
	lunar_phase = fase

func _on_finish_turn_button_down() -> void:
	if actual_turn == TurnState.PLAYER_TURN:
		start_enemy_turn()

func _on_attack_button_down() -> void:
	if actual_turn != TurnState.PLAYER_TURN:
		print("No puedes jugar cartas, es el turno del enemigo.")
		return
		
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty():
		print("Selecciona una carta de tu mano primero.")
		return

	if cm.selected_cards.size() > 1:
		print("Solo puedes jugar una carta a la vez")
		return
	
	var carta_a_jugar = cm.selected_cards[0]
	var objetivo = get_current_target()
	
	var requiere_enemigo = false
	
	if carta_a_jugar.card_data.type == CardData.CardType.NORMAL and carta_a_jugar.card_data.card_type_action == CardData.CardTypeAction.DAMAGE:
		requiere_enemigo = true
	
	for effect in carta_a_jugar.card_data.effects:
		if effect and effect.target_type == Effect.TargetType.SINGLE_ENEMY:
			requiere_enemigo = true
			break
			
	if requiere_enemigo and not objetivo:
		print("Selecciona un enemigo objetivo antes de presionar Jugar.")
		return
	
	# Si no requiere enemigo (como StealCards), "objetivo" pasará como null tranquilamente
	print("Confirmando acción: Jugando ", carta_a_jugar.card_data.card_name)
	
	cm.play_card(carta_a_jugar, objetivo)
	cm.selected_cards.clear()
	
func _on_sacrifice_button_down() -> void:
	if actual_turn != TurnState.PLAYER_TURN: return
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty(): return
	cm.sacrifice_card()
