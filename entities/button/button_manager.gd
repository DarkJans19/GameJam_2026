extends Node2D

# Constants
const OFFSET_SELECTION = 20


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func connect_button_signals(button):
	button.connect("hovered", on_hovered_over_button)
	button.connect("hovered_off", on_hovered_off_button)


func connect_card_manager_signals(card_manager):
	card_manager.connect("selected_cards", selected_cards)


func on_hovered_over_button(button):
	high_light_button(button, true)


func on_hovered_off_button(button):
	high_light_button(button, false)


func high_light_button(button, hovered):
	if hovered:
		button.scale = Vector2(1.05, 1.05)
		button.z_index = 2
	else:
		button.scale = Vector2(1, 1)
		button.z_index = 1	




