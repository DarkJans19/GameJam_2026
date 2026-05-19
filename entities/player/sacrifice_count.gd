extends Control
class_name SacrificeCountHUD

const ICONO_SACRIFICIO = preload("res://assets/UI/UI Energia.png")
@onready var icono_estado: Sprite2D = $HBoxContainer/Sprite2D
@onready var texto_sacrificio: Label = $HBoxContainer/Label

func _ready() -> void:
	add_to_group("sacrifice_hud")
	
	if icono_estado:
		icono_estado.texture = ICONO_SACRIFICIO
	
	var combat_manager = get_tree().get_first_node_in_group("CombatManager")
	if combat_manager:
		_conectar_con_combat_manager(combat_manager)
	else:
		call_deferred("_buscar_combat_manager_retrasado")

func _buscar_combat_manager_retrasado() -> void:
	var combat_manager = get_tree().get_first_node_in_group("CombatManager")
	if combat_manager:
		_conectar_con_combat_manager(combat_manager)

func _conectar_con_combat_manager(combat_manager: Node) -> void:
	if combat_manager.has_signal("puntos_sacrificio_cambiados"):
		if not combat_manager.puntos_sacrificio_cambiados.is_connected(_on_puntos_sacrificio_cambiados):
			combat_manager.puntos_sacrificio_cambiados.connect(_on_puntos_sacrificio_cambiados)
		_actualizar_interfaz(combat_manager.puntos_sacrificio)

func _on_puntos_sacrificio_cambiados(nuevos_puntos: int) -> void:
	_actualizar_interfaz(nuevos_puntos)

func _actualizar_interfaz(puntos: int) -> void:
	if not texto_sacrificio: return
	
	texto_sacrificio.text = "x" + str(puntos)
