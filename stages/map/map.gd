extends Control
class_name Map

const PLAYER_HEIGHT_OFFSET := 25

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
@onready var pause_menu : PauseMenu = $Pause

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
	player.z_index = 10
	pause_menu.z_index = 11

	_refresh_map()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.toggle_pause()

func _refresh_map() -> void:
	for event_name in event_nodes.keys():
		_set_event_enabled(
			event_nodes[event_name],
			false
		)

	if game_manager.current_event < EVENT_STEPS.size():
		for event_name in EVENT_STEPS[game_manager.current_event]:
			_set_event_enabled(
				event_nodes[event_name],
				true
			)

	if game_manager.last_selected_event == "":
		var first_event := EVENT_STEPS[0][0]

		_position_player_initial(
			event_nodes[first_event]
		)
	else:
		_position_player_completed(
			event_nodes[game_manager.last_selected_event]
		)

func _position_player_initial(target_node: Control) -> void:
	var target_center := (
		target_node.global_position +
		(target_node.size * 0.5)
	)

	var player_size := player.size

	player.global_position = Vector2(
		target_center.x - (player_size.x * 0.25),
		target_node.global_position.y - player_size.y + 15
	)

func _position_player_completed(target_node: Control) -> void:
	var target_center := (
		target_node.global_position +
		(target_node.size * 0.5)
	)

	var player_size := player.size

	player.global_position = Vector2(
		target_center.x - (player_size.x * 0.25),
		target_node.global_position.y
	)

func _on_event_gui_input(
	event: InputEvent,
	event_name: String
) -> void:

	print("RECIBIDO:", event_name)
	print("CURRENT EVENT:", game_manager.current_event)

	if not _is_event_selectable(event_name):
		print("NO SELECCIONABLE")
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("CAMBIANDO ESCENA")
			_select_event(event_name)

func _is_event_selectable(event_name: String) -> bool:
	if game_manager.current_event >= EVENT_STEPS.size():
		return false

	return (
		event_name in EVENT_STEPS[game_manager.current_event]
	)

func _select_event(event_name: String) -> void:
	var scene_path := ""

	if event_name in [
		"Enemy_event",
		"Enemy_event2"
	]:
		game_manager.etapa_combate_actual = 0
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name == "Enemy_event3":
		game_manager.etapa_combate_actual = 1
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name in [
		"Enemy_event4",
		"Enemy_event5",
		"Enemy_event6"
	]:
		game_manager.etapa_combate_actual = 2
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name == "Boss_event":
		game_manager.etapa_combate_actual = 3
		scene_path = "res://stages/combat/combat.tscn"

	elif event_name.begins_with("Shop_event"):
		scene_path = "res://stages/shop/shop.tscn"

	elif event_name.begins_with("Random_event"):
		scene_path = "res://stages/random/random.tscn"

	if scene_path == "":
		push_error(
			"No se asignó escena para: " +
			event_name
		)
		return

	game_manager.last_selected_event = event_name
	game_manager.current_event += 1

	print("CARGANDO:", scene_path)

	get_tree().change_scene_to_file(scene_path)

func _set_event_enabled(
	event_node: Control,
	enabled: bool
) -> void:

	event_node.mouse_filter = (
		Control.MOUSE_FILTER_STOP
		if enabled
		else Control.MOUSE_FILTER_IGNORE
	)

	event_node.modulate = (
		Color(1, 1, 1, 1)
		if enabled
		else Color(1, 1, 1, 0.35)
	)

func _on_pause_pressed() -> void:
	pause_menu.toggle_pause()
