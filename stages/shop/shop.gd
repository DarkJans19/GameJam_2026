extends Control
class_name shop

@onready var descripcion_general: RichTextLabel = $vida/ColorRect/DescripcionGeneral
@onready var salir_btn: Button = $vida/salir
@onready var objeto_carta_lunar: Control = $ObjetoCartaLunar
@onready var sprite_luna: Sprite2D = $ObjetoCartaLunar/cartaLunar
@onready var btn_luna: Button = $vida/comprarLuna
@onready var label_luna: Label = $vida/labelLuna
@onready var descripcion_carta: RichTextLabel = $vida/ColorRect2/DescripcionCartaLunar
@onready var label_mejora: Label = $mejora/Label
@onready var btn_mejora: Button = $mejora/comprarMejora
@onready var label_vida: Label = $vida/Label
@onready var btn_vida: Button = $vida/comprarVida

var precio_luna: int = 40
var precio_mejora: int = 35
var precio_vida: int = 20
var ruta_carta_ofertada: String = ""
var card_data_ofertada: Resource = null
var contenedor_carta_ui: Control

func _ready() -> void:
	randomize()
	if descripcion_carta:
		contenedor_carta_ui = descripcion_carta.get_parent()
		if contenedor_carta_ui: contenedor_carta_ui.hide() 
	
	if not game_manager.oro_cambiado.is_connected(_on_global_data_changed):
		game_manager.oro_cambiado.connect(_on_global_data_changed)
	if not game_manager.vida_cambiada.is_connected(_on_global_health_changed):
		game_manager.vida_cambiada.connect(_on_global_health_changed)
		
	_conectar_seniales()
	_inicializar_tienda()
	_mostrar_estado_actual()
	_actualizar_interfaz_precios()

func _on_global_data_changed(nuevo_oro: int) -> void:
	_mostrar_estado_actual()

func _on_global_health_changed(actual: int, maximo: int) -> void:
	_mostrar_estado_actual()

func _conectar_seniales() -> void:
	if salir_btn and not salir_btn.pressed.is_connected(_on_salir_pressed):
		salir_btn.pressed.connect(_on_salir_pressed)
	if btn_luna and not btn_luna.pressed.is_connected(_on_comprar_luna_pressed):
		btn_luna.pressed.connect(_on_comprar_luna_pressed)
	if btn_mejora and not btn_mejora.pressed.is_connected(_on_comprar_mejora_pressed):
		btn_mejora.pressed.connect(_on_comprar_mejora_pressed)
	if btn_vida and not btn_vida.pressed.is_connected(_on_comprar_vida_pressed):
		btn_vida.pressed.connect(_on_comprar_vida_pressed)
	if objeto_carta_lunar:
		if not objeto_carta_lunar.mouse_entered.is_connected(_on_carta_lunar_mouse_entered):
			objeto_carta_lunar.mouse_entered.connect(_on_carta_lunar_mouse_entered)
		if not objeto_carta_lunar.mouse_exited.is_connected(_on_carta_lunar_mouse_exited):
			objeto_carta_lunar.mouse_exited.connect(_on_carta_lunar_mouse_exited)

func _inicializar_tienda() -> void:
	if objeto_carta_lunar:
		objeto_carta_lunar.mouse_filter = Control.MOUSE_FILTER_STOP
	var pool_disponible = game_manager.obtener_cartas_disponibles_para_ganar()
	if pool_disponible.is_empty():
		pool_disponible = game_manager.mazo_jugador
	if not pool_disponible.is_empty():
		ruta_carta_ofertada = pool_disponible.pick_random()
		card_data_ofertada = load(ruta_carta_ofertada)
		if card_data_ofertada and sprite_luna:
			sprite_luna.texture = card_data_ofertada.image
			sprite_luna.scale = Vector2(2.5, 2.5)
	else:
		if btn_luna: btn_luna.disabled = true
		if label_luna: label_luna.text = "Agotado"

func _actualizar_interfaz_precios() -> void:
	if btn_luna: btn_luna.text = "Comprar"
	if label_luna: label_luna.text = "Carta Lunar " + str(precio_luna) + "g"
	if label_mejora: label_mejora.text = "Mejora " + str(precio_mejora) + "g"
	if label_vida: label_vida.text = "Vida (25 HP) " + str(precio_vida) + "g"

func _on_comprar_luna_pressed() -> void:
	if ruta_carta_ofertada == "" or card_data_ofertada == null: return
	if game_manager.oro >= precio_luna:
		_on_carta_lunar_mouse_exited()
		game_manager.modificar_oro(-precio_luna)
		game_manager.agregar_carta_al_mazo(ruta_carta_ofertada)
		if btn_luna: btn_luna.disabled = true
		if label_luna: label_luna.text = "Vendido"
		if sprite_luna: sprite_luna.texture = null
		ruta_carta_ofertada = ""
		card_data_ofertada = null
	else:
		_mostrar_feedback("[color=red]Oro insuficiente.[/color]")

func _on_comprar_mejora_pressed() -> void:
	if game_manager.oro >= precio_mejora:
		game_manager.modificar_oro(-precio_mejora)
		game_manager.vida_max_jugador += 20
		game_manager.curar_jugador(20)
		if btn_mejora: btn_mejora.disabled = true
		if label_mejora: label_mejora.text = "Vendido"
	else:
		_mostrar_feedback("[color=red]Oro insuficiente.[/color]")

func _on_comprar_vida_pressed() -> void:
	if game_manager.vida_actual_jugador >= game_manager.vida_max_jugador:
		_mostrar_feedback("Salud al máximo.")
		return
	if game_manager.oro >= precio_vida:
		game_manager.modificar_oro(-precio_vida)
		game_manager.curar_jugador(25)
	else:
		_mostrar_feedback("[color=red]Oro insuficiente.[/color]")

func _on_carta_lunar_mouse_entered() -> void:
	if ruta_carta_ofertada == "" or card_data_ofertada == null: return
	_show_card_description()

func _on_carta_lunar_mouse_exited() -> void:
	if contenedor_carta_ui: contenedor_carta_ui.hide()

func _show_card_description() -> void:
	if descripcion_carta and card_data_ofertada and contenedor_carta_ui:
		descripcion_carta.clear()
		var data = card_data_ofertada
		var moon_phase_str = "NORMAL"
		if data.get("type") != null:
			moon_phase_str = str(data.type)
		var texto_completo = "[center][b]" + data.card_name.to_upper() + "[/b]\n"
		texto_completo += "[color=yellow]Costo: " + str(data.sacrifice_cost) + "[/color] | [color=magenta]" + moon_phase_str + "[/color]\n"
		texto_completo += data.description + "[/center]"
		descripcion_carta.append_text(texto_completo)
		contenedor_carta_ui.show()

func _mostrar_estado_actual() -> void:
	if descripcion_general:
		descripcion_general.clear()
		var estado_texto = "[center][b]TIENDA ESTELAR[/b]\n"
		estado_texto += "Oro: [color=yellow]" + str(game_manager.oro) + "[/color] | "
		estado_texto += "HP: [color=green]" + str(game_manager.vida_actual_jugador) + "/" + str(game_manager.vida_max_jugador) + "[/color]\n\n"
		estado_texto += "\"Inspecciona la mercancía pasando el cursor.\"[/center]"
		descripcion_general.append_text(estado_texto)

func _mostrar_feedback(texto: String) -> void:
	if descripcion_general:
		descripcion_general.clear()
		var estado_texto = "[center][b]TIENDA ESTELAR[/b]\n"
		estado_texto += "Oro: [color=yellow]" + str(game_manager.oro) + "[/color] | "
		estado_texto += "HP: [color=green]" + str(game_manager.vida_actual_jugador) + "/" + str(game_manager.vida_max_jugador) + "[/color]\n\n"
		estado_texto += texto + "[/center]"
		descripcion_general.append_text(estado_texto)

func _on_salir_pressed() -> void:
	if salir_btn: salir_btn.disabled = true
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://stages/map/map.tscn")
