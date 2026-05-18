extends Control

func _ready() -> void:
	pass


func _on_play_button_pressed() -> void:
	game_manager.call("reset_progress")
	get_tree().change_scene_to_file("res://stages/map/map.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/options/options.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
