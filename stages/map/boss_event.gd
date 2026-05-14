extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_children_mouse_filter(self)


func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

		_set_children_mouse_filter(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("local gui_input clicked:", get_name())
		if get_parent() and get_parent().has_method("_on_event_gui_input"):
			get_parent()._on_event_gui_input(event, get_name())
		return
	if event is InputEventMouseButton:
		print("local gui_input other:", get_name(), event.button_index, event.pressed)
		if get_parent() and get_parent().has_method("_on_event_gui_input"):
			get_parent()._on_event_gui_input(event, get_name())
