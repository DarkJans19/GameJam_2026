extends Node2D
class_name CombatManager

signal jugador_selecciona_enemigo
signal ataque_iniciado
signal puntos_sacrificio_cambiados(nuevos_puntos: int)

enum StageType { EARLY, MID, LATE, BOSS }
enum TurnState { START_BATTLE, FINISH_BATTLE, PLAYER_TURN, ENEMY_TURN }

enum LunarPhase { 
	NEW_MOON,         # Cuadro 1: Luna Nueva (Completamente oscura)
	WAXING_CRESCENT,  # Cuadro 2: Luna Creciente
	FIRST_QUARTER,    # Cuadro 3: Cuarto Creciente (Media Luna)
	WAXING_GIBBOUS,    # Cuadro 4: Gibosa Creciente
	FULL_MOON,        # Cuadro 5: Luna Llena
	WANING_GIBBOUS,   # Cuadro 6: Gibosa Menguante
	LAST_QUARTER,     # Cuadro 7: Cuarto Menguante (Media Luna)
	WANING_CRESCENT,  # Cuadro 8: Luna Menguante
}


const MOON_PHASE_FRAMESr = {
	LunarPhase.NEW_MOON: 3,
	LunarPhase.WAXING_CRESCENT: 2,
	LunarPhase.FIRST_QUARTER: 5,
	LunarPhase.WAXING_GIBBOUS: 4,
	LunarPhase.FULL_MOON: 1,
	LunarPhase.WANING_GIBBOUS: 0,
	LunarPhase.LAST_QUARTER: 7,
	LunarPhase.WANING_CRESCENT: 6
}


const MOON_PHASE_FRAMESl = {
	LunarPhase.NEW_MOON: 5,
	LunarPhase.WAXING_CRESCENT: 4,
	LunarPhase.FIRST_QUARTER: 1,
	LunarPhase.WAXING_GIBBOUS: 0,
	LunarPhase.FULL_MOON: 7,
	LunarPhase.WANING_GIBBOUS: 6,
	LunarPhase.LAST_QUARTER: 3,
	LunarPhase.WANING_CRESCENT: 2
}

# Ya no necesitas MOON_PHASE_FRAMES porque el Enum coincide con el cuadro (0 al 7)

const MOON_PHASE_NAMES_ES = {
	LunarPhase.FULL_MOON: "Luna Llena",
	LunarPhase.WANING_GIBBOUS: "Gibosa Menguante",
	LunarPhase.LAST_QUARTER: "Cuarto Menguante",
	LunarPhase.WANING_CRESCENT: "Luna Menguante",
	LunarPhase.NEW_MOON: "Luna Nueva",
	LunarPhase.WAXING_CRESCENT: "Luna Creciente",
	LunarPhase.FIRST_QUARTER: "Cuarto Creciente",
	LunarPhase.WAXING_GIBBOUS: "Gibosa Creciente"
}

var lunar_phase = LunarPhase.NEW_MOON:
	set(val):
		lunar_phase = val
		_actualizar_sprite_luna()
		_actualizar_texto_luna() # <-- Llama a la actualización de texto aquí

var actual_turn: TurnState = TurnState.START_BATTLE

# Enemies
const BATLASER = preload("res://entities/enemy/especific_enemies/batlaser.tres")
const BEE = preload("res://entities/enemy/especific_enemies/bee.tres")
const CAT_ALIEN = preload("res://entities/enemy/especific_enemies/cat_alien.tres")
const GALAPAGOS = preload("res://entities/enemy/especific_enemies/galapagus.tres")
const MARCO = preload("res://entities/enemy/especific_enemies/marco.tres")
const HENRIK = preload("res://entities/enemy/especific_enemies/henrik.tres")
const RATONCOPTERO = preload("res://entities/enemy/especific_enemies/ratoncoptero.tres")

# Bosses
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
var puntos_sacrificio : int = 0:
	set(val):
		puntos_sacrificio = val
		emit_signal("puntos_sacrificio_cambiados", puntos_sacrificio)

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
@onready var moon_phases_sprite: AnimatedSprite2D = $Fases_lunares

@onready var faseLunarLabel: Label = $SacrificeCount/faseLunarLabel
@onready var finish_turn_button = $FinishTurn
@onready var uppermoon: Sprite2D = $Uppermoon
@onready var leftmoon: Sprite2D = $leftmoon
@onready var rigthmoon: Sprite2D = $rightmoon

@onready var pause_menu : PauseMenu = $Pause
@onready var victory_screen : VictoryScreen = $Victory
@onready var defeat_screen : LoseScreen = $Lose

# Audio
@onready var button_effect = $button_effect
@onready var enemy_select_effect = $enemy_select
@onready var music = $music

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
	{"weight": 50, "enemies": [CAT_ALIEN, BATLASER]},
	{"weight": 50, "enemies": [RATONCOPTERO, BEE]}
]
var late_formations : Array = [
	{"weight": 50, "enemies": [CAT_ALIEN, BATLASER, BEE]},
	{"weight": 50, "enemies": [MARCO, GALAPAGOS]},
]
var boss_formations : Array = [
	{"weight": 89, "enemies": [CARISTAN]},
	{"weight": 10, "enemies": [HEZEQUIAH]},
	{"weight": 1, "enemies": [HENRIK]}
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
	_actualizar_texto_luna()
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

	if music:
			if enemies_data.has(CARISTAN):
				music.stream = preload("res://assets/Audios/battle_2_theme.mp3") # Pon tu ruta real aquí
				music.play()
			elif enemies_data.has(HEZEQUIAH):
				music.stream = preload("res://assets/Audios/Hezequiah Theme.mp3")
				music.play()
			else:
				_reproducir_musica_por_defecto_etapa()

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

# Función auxiliar para limpiar el código de las etapas normales
func _reproducir_musica_por_defecto_etapa() -> void:
	match current_stage:
		StageType.EARLY:
			music.stream = preload("res://assets/Audios/Battle Theme.mp3")
		StageType.MID:
			music.stream = preload("res://assets/Audios/Battle Theme.mp3")
		StageType.LATE:
			music.stream = preload("res://assets/Audios/Battle Theme.mp3")
		StageType.BOSS:
			music.stream = preload("res://assets/Audios/battle_2_theme.mp3") 
	music.play()

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

func establecer_objetivo(personaje) -> void: 
	personaje_objetivo = personaje
	enemy_select_effect.play()

func iniciar_ataque() -> void:
	emit_signal("ataque_iniciado")
	personaje_seleccionado.atacar_personaje(personaje_objetivo)

func avanzar_fase_del_juego() -> void:
	lunar_phase = (lunar_phase + 1) % 8 as LunarPhase
	print("La nueva fase del juego es la número: ", lunar_phase)

func change_phase(fase: LunarPhase) -> void:
	lunar_phase = fase

func _actualizar_sprite_luna() -> void:
	if moon_phases_sprite:
		moon_phases_sprite.frame = lunar_phase
	if uppermoon:
		uppermoon.frame = lunar_phase
	if leftmoon and MOON_PHASE_FRAMESl.has(lunar_phase):
		leftmoon.frame = MOON_PHASE_FRAMESl[lunar_phase] 
	if rigthmoon and MOON_PHASE_FRAMESr.has(lunar_phase):
		rigthmoon.frame = MOON_PHASE_FRAMESr[lunar_phase] 
			
func _actualizar_texto_luna() -> void:
	if faseLunarLabel and MOON_PHASE_NAMES_ES.has(lunar_phase):
		faseLunarLabel.text = MOON_PHASE_NAMES_ES[lunar_phase]

func _on_finish_turn_button_down() -> void:
	button_effect.play()
	if actual_turn == TurnState.PLAYER_TURN:
		start_enemy_turn()

func _on_attack_button_down() -> void:
	button_effect.play()
	if actual_turn != TurnState.PLAYER_TURN: return
		
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty(): return
	
	var carta_a_jugar = cm.selected_cards[0]
	var objetivo = get_current_target()

	if carta_a_jugar.card_data.type == CardData.CardType.COMODIN:
		var fase_correcta = true
		for effect in carta_a_jugar.card_data.effects:
			if effect and "requires_specific_phase" in effect and effect.requires_specific_phase:
				if effect.required_lunar_phase != lunar_phase:
					fase_correcta = false
					break
		if not fase_correcta:
			print("Fase incorrecta: Este comodín no se puede jugar en la fase lunar actual.")
			return
	
	if objetivo == null or not is_instance_valid(objetivo):
		print("Por favor, selecciona un enemigo antes de presionar atacar.")
		return

	print("Confirmando acción: Intentando jugar ", carta_a_jugar.card_data.card_name)
	
	var se_pudo_jugar = cm.play_card(carta_a_jugar, objetivo)
	
	if se_pudo_jugar:
		cm.selected_cards.clear()
		await get_tree().process_frame
		verificar_estado_batalla()
	
func _on_sacrifice_button_down() -> void:
	button_effect.play()
	if actual_turn != TurnState.PLAYER_TURN: return
	var cm = get_tree().get_first_node_in_group("CardManager")
	if not cm or cm.selected_cards.is_empty(): return
	
	cm.sacrifice_card()
	print(puntos_sacrificio)
	
	print("[Combat] Cartas sacrificadas. Puntos actuales: ", puntos_sacrificio)

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
	button_effect.play()
	pause_menu.toggle_pause()
