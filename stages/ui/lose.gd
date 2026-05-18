extends Control
class_name LoseScreen

func _ready() -> void:
	print("[LoseScreen] El jugador ha caído en combate.")

func _on_button_pressed() -> void:
	get_tree().paused = false
	hide()
	await get_tree().process_frame
	game_manager.reset_progress()
	get_tree().change_scene_to_file("res://stages/menu/menu.tscn")
