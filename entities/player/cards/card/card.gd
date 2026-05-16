extends Node2D

signal hovered
signal hovered_off
signal selected
signal show_description
signal hide_description

@export var card_data: CardData = CardData.new()

@onready var sprite_visual: Sprite2D = $Sprite2D 
@onready var label_nombre_carta: RichTextLabel = $card_name
# @onready var label_moon_phase: RichTextLabel = $moon_phase
@onready var label_sacrifice_cost : RichTextLabel = $sacrifice_cost
@onready var description : RichTextLabel = $description
@onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = 3
	timer.one_shot = true
	
	# In this case all cards must be childs of CardManager otherwise will fail
	get_parent().connect_card_signals(self)
	actualizar_estado_visual()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func actualizar_estado_visual():
	if card_data != null:
		sprite_visual.texture = card_data.image
		label_nombre_carta.add_text(card_data.card_name)
		label_sacrifice_cost.add_text(str(card_data.sacrifice_cost))


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
