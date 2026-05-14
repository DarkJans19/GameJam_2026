extends Control
class_name Map

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

const EVENT_SCENES := {
	"Enemy_event": "res://stages/combat/combat.tscn",
	"Enemy_event2": "res://stages/combat/combat.tscn",
	"Enemy_event3": "res://stages/combat/combat.tscn",
	"Enemy_event4": "res://stages/combat/combat.tscn",
	"Enemy_event5": "res://stages/combat/combat.tscn",
	"Enemy_event6": "res://stages/combat/combat.tscn",
	"Random_event": "res://stages/map/random_event.tscn",
	"Random_event2": "res://stages/map/random_event.tscn",
	"Random_event3": "res://stages/map/random_event.tscn",
	"Random_event4": "res://stages/map/random_event.tscn",
	"Random_event5": "res://stages/map/random_event.tscn",
	"Random_event6": "res://stages/map/random_event.tscn",
	"Shop_event": "res://stages/map/shop_event.tscn",
	"Shop_event2": "res://stages/map/shop_event.tscn",
	"Boss_event": "res://stages/map/boss_event.tscn",
}

static var current_event: int = 0

@onready var player: TextureRect = $Player
@onready var event_nodes: Dictionary = {
	"Enemy_event": $Enemy_event,
	"Random_event": $Random_event,
	"Shop_event": $Shop_event,
	"Boss_event": $Boss_event,
	"Enemy_event2": $Enemy_event2,
	"Random_event2": $Random_event2,
	"Random_event3": $Random_event3,
	"Enemy_event3": $Enemy_event3,
	"Enemy_event4": $Enemy_event4,
	"Enemy_event5": $Enemy_event5,
	"Enemy_event6": $Enemy_event6,
	"Shop_event2": $Shop_event2,
	"Random_event4": $Random_event4,
	"Random_event5": $Random_event5,
	"Random_event6": $Random_event6,
}

static func reset_progress() -> void:
	current_event = 0

func _ready() -> void:
	_connect_events()
	_refresh_map()

func _connect_events() -> void:
	for event_name in event_nodes.keys():
		var event_node: Control = event_nodes[event_name]
		event_node.gui_input.connect(_on_event_gui_input.bind(event_name))

func _refresh_map() -> void:
	for step_index in range(EVENT_STEPS.size()):
		for event_name in EVENT_STEPS[step_index]:
			_set_event_enabled(event_nodes[event_name], step_index == current_event)

	if current_event < EVENT_STEPS.size():
		var active_event_name: String = EVENT_STEPS[current_event][0]
		player.global_position = event_nodes[active_event_name].global_position

func _on_event_gui_input(event: InputEvent, event_name: String) -> void:
	# temporary debug prints to verify clicks reach the map
	if not _is_event_selectable(event_name):
		print("gui_input ignored - not selectable:", event_name)
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("gui_input clicked:", event_name)
			_select_event(event_name)

func _is_event_selectable(event_name: String) -> bool:
	if current_event >= EVENT_STEPS.size():
		return false

	return event_name in EVENT_STEPS[current_event]

func _select_event(event_name: String) -> void:
	var scene_path: String = EVENT_SCENES.get(event_name, "")
	if scene_path == "":
		return

	player.global_position = event_nodes[event_name].global_position
	current_event += 1
	_refresh_map()
	get_tree().change_scene_to_file(scene_path)

func _set_event_enabled(event_node: Control, enabled: bool) -> void:
	_set_control_mouse_filter(event_node, Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE)
	event_node.modulate = Color(1, 1, 1, 1) if enabled else Color(1, 1, 1, 0.35)

func _set_control_mouse_filter(node: Node, filter_value: Control.MouseFilter) -> void:
	if node is Control:
		(node as Control).mouse_filter = filter_value

	for child in node.get_children():
		_set_control_mouse_filter(child, filter_value)
