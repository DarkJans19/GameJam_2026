extends Control
class_name VictoryScreen

@onready var label_oro: Label = $LabelOro

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	print("[VictoryScreen] ¡Victoria detectada!")
	_actualizar_texto_recompensa()

func _actualizar_texto_recompensa() -> void:
	if label_oro:
		label_oro.text = "Oro acumulado actual: " + str(game_manager.oro) + "g"


func _on_button_pressed() -> void:
	print("[VictoryScreen] El jugador continúa su camino hacia el mapa.")
	get_tree().paused = false
	hide()
	await get_tree().process_frame
	game_manager.reset_progress()
	get_tree().change_scene_to_file("res://stages/map/map.tscn")
