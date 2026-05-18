extends Control
class_name VictoryScreen

@onready var label_oro: Label = $CenterContainer/VBoxContainer/LabelOro

func _ready() -> void:
	# Bloqueamos el procesamiento del fondo (opcional) o lo manejamos mediante UI activa
	print("[VictoryScreen] ¡Victoria detectada!")
	_actualizar_texto_recompensa()

func _actualizar_texto_recompensa() -> void:
	if label_oro:
		# Mostramos el oro actual que posee el jugador reflejado en el GameManager global
		label_oro.text = "Oro acumulado actual: " + str(game_manager.oro) + "g"

func _on_continuar_pressed() -> void:
	print("[VictoryScreen] El jugador continúa su camino hacia el mapa.")
	# Despausamos el árbol en caso de que el CombatManager lo haya congelado
	get_tree().paused = false
	get_tree().change_scene_to_file("res://stages/map/map.tscn")
