extends Control

@export var world_index:int = 0

func _ready() -> void:
	size = Vector2(64, 64)
	custom_minimum_size = Vector2(64, 64)

	mouse_filter = Control.MOUSE_FILTER_STOP

	_set_children_mouse_filter(self)

	print(name, " SIZE: ", size)

func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

		_set_children_mouse_filter(child)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("CLICK:", name)

			if get_parent() and get_parent().has_method("_on_event_gui_input"):
				get_parent()._on_event_gui_input(event, name)
