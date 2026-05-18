extends Node2D

signal hovered
signal hovered_off
signal selected
signal show_description
signal hide_description

@export var card_data: CardData = CardData.new()

@onready var sprite_visual: Sprite2D = $Sprite2D 
@onready var timer = $Timer
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	timer.wait_time = 0.4
	timer.one_shot = true
	
	var card_manager = get_node("../../CardManager")
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(self)
	
	actualizar_estado_visual()
	ajustar_colision_al_sprite()

func actualizar_estado_visual():
	if card_data != null and sprite_visual:
		sprite_visual.texture = card_data.image

func ajustar_colision_al_sprite():
	if sprite_visual.texture and collision_shape.shape is RectangleShape2D:
		var texture_size = sprite_visual.texture.get_size()
		collision_shape.shape.size = texture_size

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)
	timer.start()
	
func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
	timer.stop()
	emit_signal("hide_description", self)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("selected", self)

func _on_timer_timeout() -> void:
	emit_signal("show_description", self)
