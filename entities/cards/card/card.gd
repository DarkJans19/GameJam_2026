extends Node2D

signal hovered
signal hovered_off
signal selected
signal description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# In this case all cards must be childs of CardManager otherwise will fail
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)
	
	
func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("selected", self)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		emit_signal("description", self)
