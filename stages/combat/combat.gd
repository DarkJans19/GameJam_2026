extends Node2D
class_name CombatManager

signal jugador_selecciona_enemigo
signal ataque_iniciado

enum StageType { EARLY, MID, LATE, BOSS }
enum TurnState { START_BATTLE, FINISH_BATTLE, PLAYER_TURN, ENEMY_TURN }

enum LunarPhase { 
	NEW_MOON, 
	WANING_CRESCENT, 
	LAST_QUARTER,
	WANING_GIBBOUS, 
	FULL_MOON, 
	WAXING_GIBBOUS, 
	FIRST_QUARTER, 
	WAXING_CRESCENT
}

const MOON_PHASE_FRAMES = {
	LunarPhase.NEW_MOON: 2,
	LunarPhase.WAXING_CRESCENT: 5,
	LunarPhase.FIRST_QUARTER: 4,
	LunarPhase.WAXING_GIBBOUS: 1,
	LunarPhase.FULL_MOON: 0,
	LunarPhase.WANING_GIBBOUS: 7,
	LunarPhase.LAST_QUARTER: 6,
	LunarPhase.WANING_CRESCENT: 3
}

var lunar_phase = LunarPhase.NEW_MOON:
	set(val):
		lunar_phase = val
		_actualizar_sprite_luna()

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

var skip_next_enemy_turn : bool = false

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
@onready var moon_phases_sprite: Sprite2D = $moonPhases

@onready var finish_turn_button = $FinishTurn

@onready var pause_menu : PauseMenu = $Pause
@onready var victory_screen : VictoryScreen = $Victory
@onready var defeat_screen : LoseScreen = $Lose

var enemy_scene : PackedScene = preload("res://entities/enemy/enemy.tscn")
const PAUSE_MENU_SCENE = preload("res://stages/ui/pause.tscn")
const VICTORY_SCREEN_SCENE = preload("res://stages/ui/victory.tscn")
const DEFEAT_SCREEN_SCENE = preload("res://stages/ui/lose.tscn")

var early_formations : Array = [
	{"weight": 50, "enemies": [BATLASER]},
	{"weight": 40, "enemies": [BEE]},
	{"weight": 10, "enemies": [BEE, BATLASER]}
]
var mid_formations : Array = [
	{"weight": 50, "enemies": [CAT_ALIEN]},
	{"weight": 50, "enemies": [BEE, BEE, BEE]}
]
var late_formations : Array = [
	{"weight": 90, "enemies": [CAT_ALIEN, BATLASER, BEE]},
	{"weight": 10, "enemies": [HEZEQUIAH]}
]
var boss_formations : Array = [
	{"weight": 100, "enemies": [CARISTAN]}
]

func _ready() -> void:
	add_to_group("CombatManager")
	randomize()
	if "etapa_combate_actual" in game_manager:
		current_stage = game_manager.etapa_combate_actual as StageType
		print("[CombatManager] Iniciando combate en la etapa: ", StageType.keys()[current_stage])
	
	spawn_enemy_formation()
	await get_tree().process_frame
	enemigos = get_tree().get_nodes_in_group("enemies")
	cantidad_inicial_enemigos = enemigos.size()
	jugadores = get_tree().get_nodes_in_group("player")
	
	game_manager.vida_cambiada.connect(_on_player_life_changed)
	
	_actualizar_sprite_luna()
	start_battle()

func _on_player_life_changed(actual: int, maxima: int) -> void:
	if actual <= 0:
		mostrar_derrota()

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
			
		if not enemy_instance.is_connected("animacion_bloqueante_iniciada", func(): set_botones_bloqueados(true)):
			enemy_instance.connect("animacion_bloqueante_iniciada", func(): set_botones_bloqueados(true))
			
		if not enemy_instance.is_connected("animacion_bloqueante_terminada", func(): 
			if actual_turn == TurnState.PLAYER_TURN: set_botones_bloqueados(false)):
				enemy_instance.connect("animacion_bloqueante_terminada", func(): 
					if actual_turn == TurnState.PLAYER_TURN: set_botones_bloqueados(false))
					
func start_battle():
	actual_turn = TurnState.START_BATTLE
	if deck_node and deck_node.has_method("preparate_initial_hand"):
		deck_node.preparate_initial_hand()
	start_player_turn()

func start_player_turn():
	actual_turn = TurnState.PLAYER_TURN
	set_botones_bloqueados(false) 
	
	if deck_node and deck_node.has_method("draw_card_by_type"):
		deck_node.draw_card_by_type(2, CardData.CardType.NORMAL)
		deck_node.draw_card_by_type(2, CardData.CardType.COMODIN)
		deck_node.draw_card_by_type(2, CardData.CardType.LUNAR)

func start_enemy_turn():
	actual_turn = TurnState.ENEMY_TURN
	print("--- Enemies turn ---")
	set_botones_bloqueados(true)
	
	if skip_next_enemy_turn:
		print("[CombatManager] ¡Efecto activado! Saltando el turno de los enemigos.")
		skip_next_enemy_turn = false
		
		avanzar_fase_del_juego() 
		start_player_turn() 
		return
	
	if current_selected_enemy != null and is_instance_valid(current_selected_enemy):
		current_selected_enemy.set_selected(false)
	current_selected_enemy = null
	personaje_objetivo = null
	
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
		set_botones_bloqueados(true)

		game_manager.procesar_victoria_combate(cantidad_inicial_enemigos)

		mostrar_victoria()

func mostrar_victoria() -> void:
	get_tree().paused = true
	victory_screen.show()
	
func mostrar_derrota() -> void:
	actual_turn = TurnState.FINISH_BATTLE
	set_botones_bloqueados(true)
	get_tree().paused = true
	defeat_screen.show()

func _on_enemy_selected(new_enemy: Enemy) -> void:
	if current_selected_enemy == new_enemy: return
	if current_selected_enemy != null and is_instance_valid(current_selected_enemy):
		current_selected_enemy.set_selected(false)
	current_selected_enemy = new_enemy
	current_selected_enemy.set_selected(true)
	establecer_objetivo(new_enemy)

func get_current_target() -> Enemy:
	if is_instance_valid(current_selected_enemy) and current_selected_enemy.health > 0: 
		return current_selected_enemy
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

func _actualizar_sprite_luna() -> void:
	if moon_phases_sprite and MOON_PHASE_FRAMES.has(lunar_phase):
		moon_phases_sprite.frame = MOON_PHASE_FRAMES[lunar_phase]

func _on_finish_turn_button_down() -> void:
	if actual_turn == TurnState.PLAYER_TURN:
		start_enemy_turn()

func _on_attack_button_down() -> void:
	if actual_turn != TurnState.PLAYER_TURN: return
		
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty(): return
	
	var carta_a_jugar = cm.selected_cards[0]
	var objetivo = get_current_target()

	# Validar cartas comodin... para evitar que se eliminen)?
	if carta_a_jugar.card_data.type == CardData.CardType.COMODIN:
		var fase_correcta = true
		
		# Revisamos si alguno de los efectos bloquea la jugada por la fase
		for effect in carta_a_jugar.card_data.effects:
			if effect and "requires_specific_phase" in effect and effect.requires_specific_phase:
				if effect.required_lunar_phase != lunar_phase:
					fase_correcta = false
					break
		
		if not fase_correcta:
			print("Fase incorrecta: Este comodín no se puede jugar en la fase lunar actual.")
			return
	
	# Validación estricta para evitar que se gasten cartas solas si se pierde el objetivo
	if objetivo == null or not is_instance_valid(objetivo):
		print("Por favor, selecciona un enemigo antes de presionar atacar.")
		return

	print("Confirmando acción: Jugando ", carta_a_jugar.card_data.card_name)
	
	cm.play_card(carta_a_jugar, objetivo)
	cm.selected_cards.clear()
	
	await get_tree().process_frame
	verificar_estado_batalla()
	
func _on_sacrifice_button_down() -> void:
	if actual_turn != TurnState.PLAYER_TURN: return
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty(): return
	cm.sacrifice_card()

func set_botones_bloqueados(bloquear: bool) -> void:
	if is_instance_valid(attack_button) and attack_button is Button:
		attack_button.disabled = bloquear
	if is_instance_valid(sacrifice_button) and sacrifice_button is Button:
		sacrifice_button.disabled = bloquear
	if is_instance_valid(finish_turn_button) and finish_turn_button is Button:
		finish_turn_button.disabled = bloquear
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if actual_turn == TurnState.FINISH_BATTLE:
			return
		
		if pause_menu:
			pause_menu.toggle_pause()


func _on_pause_pressed() -> void:
	pause_menu.toggle_pause()
