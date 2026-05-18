extends Control
class_name PauseMenu

@export var return_scene : String = "res://stages/map/map.tscn"

@onready var card_container = $cardsContainer
@onready var grid_container = $cardsContainer/GridContainer
@onready var volver_btn = $cardsContainer/volver

@onready var descripcion_carta: RichTextLabel = $cardsContainer/ColorRect2/DescripcionCartaLunar

var contenedor_descripcion: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()
	
	contenedor_descripcion = descripcion_carta.get_parent()
	contenedor_descripcion.hide()

	descripcion_carta.add_theme_font_size_override("normal_font_size", 8)

	if not volver_btn.pressed.is_connected(_on_volver_pressed):
		volver_btn.pressed.connect(_on_volver_pressed)

func toggle_pause() -> void:
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	show()
	get_tree().paused = true

func resume_game() -> void:
	get_tree().paused = false
	hide()
	card_container.hide()

func abrir_coleccion() -> void:
	card_container.show()
	_cargar_cartas()

func _on_ver_cartas_pressed() -> void:
	abrir_coleccion()

func _on_volver_pressed() -> void:
	card_container.hide()
	contenedor_descripcion.hide()

func _cargar_cartas() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	grid_container.columns = 5

	for ruta_carta in game_manager.mazo_jugador:
		if not ResourceLoader.exists(ruta_carta):
			continue

		var card_data = load(ruta_carta)

		if card_data == null:
			continue

		var slot = Control.new()
		slot.custom_minimum_size = Vector2(20, 30)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP

		var texture = TextureRect.new()
		texture.texture = card_data.image
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture.custom_minimum_size = Vector2(20, 30)
		texture.position = Vector2(10, 10)
		texture.mouse_filter = Control.MOUSE_FILTER_IGNORE

		slot.add_child(texture)

		slot.mouse_entered.connect(
			func():
				_show_card_description(card_data)
		)

		slot.mouse_exited.connect(
			func():
				_hide_card_description()
		)

		grid_container.add_child(slot)

func _show_card_description(card_data) -> void:
	if descripcion_carta == null:
		return

	descripcion_carta.clear()

	var moon_phase_str = "NORMAL"

	if card_data.get("type") != null:
		moon_phase_str = str(card_data.type)

	var texto_completo = "[center][b]" + card_data.card_name.to_upper() + "[/b]\n"
	texto_completo += "[color=yellow]Costo: " + str(card_data.sacrifice_cost) + "[/color]\n"
	texto_completo += "[color=magenta]Fase: " + moon_phase_str + "[/color]\n\n"
	texto_completo += card_data.description + "[/center]"

	descripcion_carta.append_text(texto_completo)

	contenedor_descripcion.show()

func _hide_card_description() -> void:
	if contenedor_descripcion:
		contenedor_descripcion.hide()

func _on_resume_pressed() -> void:
	resume_game()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(return_scene)


func _on_button_pressed() -> void:
	get_tree().paused = false
	hide()

	await get_tree().process_frame

	game_manager.reset_progress()

	get_tree().change_scene_to_file("res://stages/menu/menu.tscn")
