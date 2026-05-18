extends Control
class_name PauseMenu

func _ready() -> void:
	# Nos aseguramos de que el menú pueda procesar inputs aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide() # Empieza oculto por defecto

func _input(event: InputEvent) -> void:
	# Si el jugador presiona la tecla Escape o la acción "ui_cancel"
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_on_resume_pressed()
		else:
			_pausar_juego()

func _pausar_juego() -> void:
	show()
	get_tree().paused = true
	print("[PauseMenu] Juego Pausado.")

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
	print("[PauseMenu] Juego Reanudado.")

func _on_retry_pressed() -> void:
	get_tree().paused = false
	print("[PauseMenu] Reiniciando el combate...")
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	print("[PauseMenu] Volviendo al mapa principal.")
	get_tree().change_scene_to_file("res://stages/map/map.tscn")
