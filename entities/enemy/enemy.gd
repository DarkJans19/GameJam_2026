extends Node2D
class_name Enemy

signal selected(enemy: Enemy)
signal animacion_bloqueante_iniciada
signal animacion_bloqueante_terminada

var current_lunar_phase : CombatManager.LunarPhase = CombatManager.LunarPhase.NEW_MOON

@export var enemy_data : EnemyData

var health : int = 0
var armor : int = 0 

var is_my_turn : bool = false
var is_busy : bool = false
var is_defending : bool = false:
	set(value):
		is_defending = value
		update_health_bar()

@onready var sprite : Sprite2D = (
	$Sprite2D
)

@onready var health_bar : ProgressBar = (
	$HealthBar
)

@onready var bar_text : Label = (
	$HealthBar/BarText
)

@onready var animation_player : AnimationPlayer = (
	$AnimationPlayer
)

@onready var selection_cursor : Sprite2D = (
	$SelectionCursor
)

# --- NUEVAS REFERENCIAS PARA EL TOOLTIP AUTÓNOMO ---
@onready var enemy_tooltip : PanelContainer = (
	$EnemyTooltip
)

@onready var tooltip_text : RichTextLabel = (
	$EnemyTooltip/TooltipText
)

func _ready() -> void:
	add_to_group("enemies")
	if selection_cursor:
		selection_cursor.hide()
	if enemy_tooltip:
		enemy_tooltip.hide()		
	if enemy_tooltip:
		enemy_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tooltip_text:
		tooltip_text.mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup() -> void:
	if enemy_data == null:
		push_error(
			"EnemyData no asignado"
		)
		return

	_setup_enemy()
	play_idle()

func _setup_enemy() -> void:
	health = enemy_data.max_health
	armor = 0
	
	health_bar.max_value = (
		enemy_data.max_health
	)
	health_bar.value = health

	if enemy_data.sprite != null:
		sprite.texture = (
			enemy_data.sprite
		)
		
	update_health_bar()

func set_selected(is_selected: bool) -> void:
	if selection_cursor:
		selection_cursor.visible = is_selected
		
func update_health_bar() -> void:
	if health_bar == null or bar_text == null:
		return
		
	health_bar.value = health
	
	var fill_style : StyleBoxFlat = health_bar.get_theme_stylebox("fill").duplicate()
	
	if is_defending:
		if fill_style:
			fill_style.bg_color = Color("888888")
		
		health_bar.add_theme_stylebox_override("fill", fill_style)
		bar_text.text = str(armor) + " " + str(health) + "/" + str(int(health_bar.max_value))
	else:
		if fill_style:
			fill_style.bg_color = Color("004f97")
			
		health_bar.add_theme_stylebox_override("fill", fill_style)
		bar_text.text = str(health) + "/" + str(int(health_bar.max_value))

func get_next_actions_string() -> String:
	if enemy_data == null:
		return "Ninguna"
		
	var actions : Array = enemy_data.moon_phase_turns.get(current_lunar_phase, [])
	if actions.is_empty():
		return "Pasar Turno"
	
	return ", ".join(actions)

func _on_mouse_detector_mouse_entered() -> void:
	if enemy_data == null or enemy_tooltip == null or tooltip_text == null:
		return
		
	tooltip_text.clear()
	
	var nombre = enemy_data.enemy_name.to_upper()
	var accion_siguiente = get_next_actions_string()
	
	var texto_completo = nombre + "\n"
	texto_completo += "Acción: " + accion_siguiente
	
	tooltip_text.add_text(texto_completo)
	
	var ancho_deseado : float = 90.0
	var alto_deseado : float = 35.0
	
	enemy_tooltip.custom_minimum_size = Vector2(ancho_deseado, alto_deseado)
	enemy_tooltip.size = Vector2(ancho_deseado, alto_deseado)
	
	tooltip_text.custom_minimum_size = Vector2(ancho_deseado, alto_deseado)
	tooltip_text.size = Vector2(ancho_deseado, alto_deseado)
	
	tooltip_text.add_theme_font_size_override("normal_font_size", 8)
	
	var x_centrado = -1.25* ancho_deseado
	
	var y_elevado = -25.0 
	
	enemy_tooltip.position = Vector2(x_centrado, y_elevado)
	
	enemy_tooltip.show()
	print("[Enemy Tooltip] Mostrando datos maquetados de: " + nombre)
	
func _on_mouse_detector_mouse_exited() -> void:
	if enemy_tooltip:
		enemy_tooltip.hide()

func start_turn() -> void:
	if is_busy:
		return

	is_my_turn = true
	is_defending = false
	armor = 0 
	
	var combat = get_tree().get_first_node_in_group("CombatManager")
	if combat:
		current_lunar_phase = combat.lunar_phase

	print(enemy_data.enemy_name + " inicia turno")
	print("Fase lunar actual: " + str(current_lunar_phase))

	await execute_turn()
	end_turn()


func end_turn() -> void:
	is_my_turn = false
	print(enemy_data.enemy_name + " termina turno")


func execute_turn() -> void:
	var actions : Array = (
		enemy_data.moon_phase_turns.get(current_lunar_phase, [])
	)

	if actions.is_empty():
		print(enemy_data.enemy_name + " no tiene acciones")
		return

	for action_name in actions:
		if is_busy:
			return

		await execute_action(str(action_name))
		await get_tree().create_timer(0.3).timeout

func execute_action(action_name : String) -> void:
	match action_name:
		"ATTACK":
			await action_attack()
		"HEAVY ATTACK":
			await action_heavy_attack()
		"HEAL":
			await action_heal()
		"FULL HEAL":
			await action_full_heal()
		"DEFEND":
			await action_defend()
		"ADVANCE MOON":
			await action_advance_moon()
		"PASS":
			await action_pass()
		_:
			print("Accion desconocida: " + action_name)

func action_attack() -> void:
	is_busy = true
	emit_signal("animacion_bloqueante_iniciada") # <-- BLOQUEA
	print(enemy_data.enemy_name + " usa ATTACK")
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false
	emit_signal("animacion_bloqueante_terminada")

func action_heavy_attack() -> void:
	is_busy = true
	emit_signal("animacion_bloqueante_iniciada") # <-- BLOQUEA
	print(enemy_data.enemy_name + " usa HEAVY ATTACK")
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false
	emit_signal("animacion_bloqueante_terminada") # <-- LIBERA

func take_damage(amount : int) -> void:
	if is_busy:
		return

	if is_defending:
		if armor > 0:
			var damage_to_armor = min(armor, amount)
			armor -= damage_to_armor
			amount -= damage_to_armor
		amount *= 0.5

	health -= amount
	if health < 0:
		health = 0

	update_health_bar()
	print(enemy_data.enemy_name + " recibe " + str(amount) + " dany")

	is_busy = true
	emit_signal("animacion_bloqueante_iniciada") # <-- BLOQUEA BOTONES EN HURT
	play_hurt()
	await animation_player.animation_finished
	play_idle()
	is_busy = false
	emit_signal("animacion_bloqueante_terminada") # <-- LIBERA BOTONES

	if health <= 0:
		die()
		
func action_heal() -> void:
	is_busy = true
	print(enemy_data.enemy_name + " usa HEAL")
	heal(enemy_data.heal_amount)
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false

func action_full_heal() -> void:
	is_busy = true
	print(enemy_data.enemy_name + " usa FULL HEAL")
	health = enemy_data.max_health
	update_health_bar()
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false

func action_defend() -> void:
	is_busy = true
	armor = 15 
	is_defending = true
	
	print(enemy_data.enemy_name + " usa DEFEND")
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false

# Revisar esta funcion ya que combat ya tiene esta logica
func action_advance_moon() -> void:
	is_busy = true
	current_lunar_phase += 1

	if current_lunar_phase > CombatManager.LunarPhase.WANING_CRESCENT:
		current_lunar_phase = CombatManager.LunarPhase.NEW_MOON

	print(enemy_data.enemy_name + " adelanta la fase lunar a: " + str(current_lunar_phase))
	play_attack()
	await animation_player.animation_finished
	play_idle()
	is_busy = false

func action_pass() -> void:
	is_busy = true
	print(enemy_data.enemy_name + " pasa turno")
	await get_tree().create_timer(0.9).timeout
	play_idle()
	is_busy = false

func heal(amount : int) -> void:
	health += amount
	if health > enemy_data.max_health:
		health = enemy_data.max_health

	update_health_bar()
	print(enemy_data.enemy_name + " recupera " + str(amount))

func die() -> void:
	print(enemy_data.enemy_name + " muere")
	queue_free()

func play_idle() -> void:
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")

func play_attack() -> void:
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")

func play_hurt() -> void:
	if animation_player and animation_player.has_animation("hurt"):
		animation_player.play("hurt")


func _on_mouse_detector_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("selected", self)
		get_viewport().set_input_as_handled()
