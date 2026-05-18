extends Control
class_name GoldHUD

@onready var texto_oro: Label = $HBoxContainer/Label

func _ready() -> void:
	if not game_manager.oro_cambiado.is_connected(_on_oro_cambiado_global):
		game_manager.oro_cambiado.connect(_on_oro_cambiado_global)
		
	_actualizar_interfaz_oro(game_manager.oro)

func _on_oro_cambiado_global(nuevo_total: int) -> void:
	_actualizar_interfaz_oro(nuevo_total)

func _actualizar_interfaz_oro(cantidad: int) -> void:
	if texto_oro:
		texto_oro.text = str(cantidad) + " g"
