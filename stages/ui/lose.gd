extends Control
class_name LoseScreen

func _ready() -> void:
	print("[LoseScreen] El jugador ha caído en combate.")

func _on_retry_pressed() -> void:
	print("[LoseScreen] Intentando el combate de nuevo...")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	print("[LoseScreen] Regresando al mapa principal (pérdida de progreso del nodo).")
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://stages/map/map.tscn")
