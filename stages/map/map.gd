extends Control
class_name Map

const PLAYER_HEIGHT_OFFSET := 25

# Se eliminó ENEMY_SCENES porque ahora usas la escena única combat.tscn

const SHOP_SCENES := [
	"res://stages/map/shop_1.tscn",
	"res://stages/map/shop_2.tscn",
]

const RANDOM_SCENES := [
	"res://stages/map/random_1.tscn",
	"res://stages/map/random_2.tscn",
	"res://stages/map/random_3.tscn",
]

const BOSS_SCENES := [
	"res://stages/map/boss_1.tscn",
 ]

const EVENT_STEPS: Array = [
	["Enemy_event"],
	["Enemy_event2"],
	["Random_event", "Random_event2", "Random_event3"],
	["Shop_event"],
	["Enemy_event3"],
	["Enemy_event4", "Enemy_event5", "Enemy_event6"],
	["Shop_event2"],
	["Random_event4", "Random_event5", "Random_event6"],
	["Boss_event"],
]

@onready var player: TextureRect = $Player

@onready var event_nodes: Dictionary = {
	"Enemy_event": $Enemy_event,
	"Enemy_event2": $Enemy_event2,
	"Enemy_event3": $Enemy_event3,
	"Enemy_event4": $Enemy_event4,
	"Enemy_event5": $Enemy_event5,
	"Enemy_event6": $Enemy_event6,

	"Random_event": $Random_event,
	"Random_event2": $Random_event2,
	"Random_event3": $Random_event3,
	"Random_event4": $Random_event4,
	"Random_event5": $Random_event5,
	"Random_event6": $Random_event6,

	"Shop_event": $Shop_event,
	"Shop_event2": $Shop_event2,

	"Boss_event": $Boss_event,
}

func _ready() -> void:
	randomize()
	player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.z_index = 100
	_connect_events()
	_refresh_map()

func _connect_events() -> void:
	for event_name in event_nodes.keys():
		var event_node: Control = event_nodes[event_name]
		if not event_node.gui_input.is_connected(_on_event_gui_input):
			event_node.gui_input.connect(_on_event_gui_input.bind(event_name))

func _refresh_map() -> void:
	for step_index in range(EVENT_STEPS.size()):
		var enabled: bool = (step_index == (game_manager as Node).get("current_event"))
		for event_name in EVENT_STEPS[step_index]:
			_set_event_enabled(event_nodes[event_name], enabled)

	if game_manager.last_selected_event == "":
		if game_manager.current_event < EVENT_STEPS.size():
			var first_event: String = (EVENT_STEPS[game_manager.current_event][0])
			_position_player_initial(event_nodes[first_event])
	else:
		_position_player_completed(event_nodes[game_manager.last_selected_event])

func _position_player_initial(target_node: Control) -> void:
	var target_center := (target_node.global_position + (target_node.size * 0.5))
	var player_size := player.size
	player.global_position = Vector2(
		target_center.x - (player_size.x * 0.25),
		target_node.global_position.y - player_size.y + 15
	)

func _position_player_completed(target_node: Control) -> void:
	var target_center := (target_node.global_position + (target_node.size * 0.5))
	var player_size := player.size
	player.global_position = Vector2(
		target_center.x - (player_size.x * 0.25),
		target_node.global_position.y
	)

func _on_event_gui_input(event: InputEvent, event_name: String) -> void:
	if not _is_event_selectable(event_name):
		return

	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			_select_event(event_name)

func _is_event_selectable(event_name: String) -> bool:
	if game_manager.current_event >= EVENT_STEPS.size():
		return false
	return (event_name in EVENT_STEPS[game_manager.current_event])

func _select_event(event_name: String) -> void:
	var scene_path: String = ""

	# --- CONTROL DE COMBATES ---
	if event_name == "Enemy_event" or event_name == "Enemy_event2":
		game_manager.etapa_combate_actual = 0 # StageType.EARLY
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name == "Enemy_event3":
		game_manager.etapa_combate_actual = 1 # StageType.MID
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name in ["Enemy_event4", "Enemy_event5", "Enemy_event6"]:
		game_manager.etapa_combate_actual = 2 # StageType.LATE
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name == "Boss_event":
		game_manager.etapa_combate_actual = 3 # StageType.BOSS
		scene_path = "res://stages/combat/combat.tscn"

	# --- CONTROL DE TIENDAS Y EVENTOS ALEATORIOS (CORREGIDO MAYÚSCULAS) ---
	elif event_name.begins_with("Shop_event"):
		scene_path = SHOP_SCENES.pick_random()

	elif event_name.begins_with("Random_event"):
		scene_path = RANDOM_SCENES.pick_random()

	# Validación de seguridad
	if scene_path == "":
		push_error("No se asignó escena para: " + event_name)
		return

	game_manager.last_selected_event = event_name
	game_manager.current_event += 1

	# Si era el evento final del Boss, reiniciamos el progreso global y vamos al menú
	if event_name == "Boss_event":
		game_manager.reset_progress()
		get_tree().change_scene_to_file("res://stages/menu/menu.tscn")
		return

	_refresh_map()
	get_tree().change_scene_to_file(scene_path)

func _set_event_enabled(event_node: Control, enabled: bool) -> void:
	event_node.mouse_filter = (Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE)
	for child in event_node.get_children():
		if child is Control:
			child.mouse_filter = (Control.MOUSE_FILTER_IGNORE)
	event_node.modulate = (Color(1, 1, 1, 1) if enabled else Color(1, 1, 1, 0.35))
