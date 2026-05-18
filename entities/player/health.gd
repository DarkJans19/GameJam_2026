extends Control
class_name PlayerHealthHUD

var shield: int = 0:
	set(val):
		shield = val
		_actualizar_interfaz_vida()

const ICONO_CORAZON = preload("res://assets/UI/UI HP.png")
const ICONO_ESCUDO = preload("res://assets/UI/UI Escudo.png")

@onready var icono_estado: Sprite2D = $HBoxContainer/Sprite2D
@onready var texto_vida: Label = $HBoxContainer/Label

func _ready() -> void:
	if not game_manager.vida_cambiada.is_connected(_on_vida_cambiada_global):
		game_manager.vida_cambiada.connect(_on_vida_cambiada_global)
	
	_actualizar_interfaz_vida()

func _on_vida_cambiada_global(actual: int, maxima: int) -> void:
	_actualizar_interfaz_vida()

func _actualizar_interfaz_vida() -> void:
	if not texto_vida or not icono_estado: return
	
	var vida_act = game_manager.vida_actual_jugador
	var vida_max = game_manager.vida_max_jugador
	
	if shield > 0:
		if icono_estado.texture != ICONO_ESCUDO:
			icono_estado.texture = ICONO_ESCUDO
		texto_vida.text = str(shield) + " " + str(vida_act) + "/" + str(vida_max)
	else:
		if icono_estado.texture != ICONO_CORAZON:
			icono_estado.texture = ICONO_CORAZON
		texto_vida.text = str(vida_act) + "/" + str(vida_max)

func ganar_armadura(cantidad: int) -> void:
	shield += cantidad
	print("[Health] Escudo temporal modificado: +", cantidad, " | Total actual: ", shield)

func recibir_damage(cantidad: int) -> void:
	var damage_final = cantidad
	
	if shield > 0:
		if shield >= cantidad:
			shield -= cantidad
			damage_final = 0
		else:
			damage_final = cantidad - shield
			shield = 0
			
	if damage_final > 0:
		game_manager.aplicar_damage_jugador(damage_final)

func _procesar_derrota() -> void:
	print("[Health] El jugador se ha quedado sin vida. Procesando fin de partida...")
