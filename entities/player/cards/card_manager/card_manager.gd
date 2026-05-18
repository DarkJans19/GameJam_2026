extends Node2D

const OFFSET_SELECTION = 15
const BASE_SCALE = Vector2(0.5, 0.5)
const HOVER_SCALE = Vector2(0.6, 0.6)

@export var descripcion_general: RichTextLabel

var selected_cards = []
var player_hand_reference
var active_hover_card = null
var contenedor_ui: Control

func _ready() -> void:
	add_to_group("CardManager")
	player_hand_reference = get_node("../PlayerHand")
	if descripcion_general:
		contenedor_ui = descripcion_general.get_parent()


func _process(delta: float) -> void:
	if active_hover_card and contenedor_ui and is_instance_valid(active_hover_card):
		var card_sprite = active_hover_card.get_node_or_null("Sprite2D")
		if card_sprite and card_sprite.texture:
			var sprite_width = card_sprite.texture.get_size().x * active_hover_card.global_scale.x
			var sprite_height = card_sprite.texture.get_size().y * active_hover_card.global_scale.y
			
			var ancho_contenedor = sprite_width * 7.0
			
			contenedor_ui.custom_minimum_size.x = ancho_contenedor
			contenedor_ui.size.x = ancho_contenedor
			
			if descripcion_general:
				descripcion_general.custom_minimum_size.x = ancho_contenedor
				descripcion_general.size.x = ancho_contenedor
				descripcion_general.add_theme_font_size_override("normal_font_size", 20)
			
			var card_screen_pos = active_hover_card.get_global_transform_with_canvas().origin
			
			var ui_pos = Vector2(
				card_screen_pos.x - (ancho_contenedor / 2),
				card_screen_pos.y - (sprite_height / 2) - contenedor_ui.size.y - 100
			)
			
			contenedor_ui.global_position = ui_pos

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	card.connect("selected", select_card)
	card.connect("show_description", show_description)
	card.connect("hide_description", hide_description)

func on_hovered_over_card(card):
	if card in selected_cards:
		return
	active_hover_card = card
	high_light_card(card, true)

func on_hovered_off_card(card):
	if card in selected_cards:
		return
	if active_hover_card == card:
		active_hover_card = null
	high_light_card(card, false)

func high_light_card(card, hovered):
	var tween = create_tween().set_parallel(true)
	if hovered:
		card.z_index = 30
		tween.tween_property(card, "scale", HOVER_SCALE, 0.1)
	else:
		card.z_index = 10 + player_hand_reference.player_hand.find(card)
		tween.tween_property(card, "scale", BASE_SCALE, 0.1)

func high_light_selected_cards(card, hovered):
	var tween = create_tween().set_parallel(true)
	var target_y = player_hand_reference.HAND_Y_POSITION
	
	if hovered:
		card.z_index = 25
		tween.tween_property(card, "scale", BASE_SCALE, 0.1)
		tween.tween_property(card, "position:y", target_y - OFFSET_SELECTION, 0.1)
	else:
		card.z_index = 10 + player_hand_reference.player_hand.find(card)
		tween.tween_property(card, "scale", BASE_SCALE, 0.1)
		tween.tween_property(card, "position:y", target_y, 0.1)

func select_card(card):
	if card in selected_cards:
		selected_cards.erase(card)
		high_light_selected_cards(card, false)
	else:
		selected_cards.append(card)
		for cards in selected_cards:
			print(selected_cards, cards.card_data.card_name)
		high_light_selected_cards(card, true)

func show_description(card):
	if descripcion_general and card.card_data and contenedor_ui:
		descripcion_general.clear()
		
		var data = card.card_data
		var moon_phase_str = CardData.CardType.keys()[data.type]
		
		var texto_completo = data.card_name.to_upper() + "\n"
		texto_completo += "Costo: " + str(data.sacrifice_cost) + "\n"
		texto_completo += "Fase: " + moon_phase_str + "\n"
		texto_completo += data.description
		
		descripcion_general.add_text(texto_completo)
		contenedor_ui.show()

func hide_description(card):
	if contenedor_ui:
		contenedor_ui.hide()


func play_card(card: Node2D, clicked_target: Node = null) -> void:
	print("carta jugada")
	if not card or not card.card_data:
		push_error("La carta enviada no contiene información (CardData)")
		return
	
	if card.card_data.effects.is_empty():
		print("La carta ", card.card_data.card_name, " no posee efectos activos.")
		# Limpiamos de la mano ANTES de liberar
		player_hand_reference.remove_cards_of_hand(card)
		card.queue_free()
		return
	
	for effect in card.card_data.effects:
		if effect and effect.has_method("effect"):
			effect.effect(clicked_target, get_tree())
		else:
			push_error("El efecto no es válido o no tiene implementado el método 'effect'")
			
	player_hand_reference.remove_cards_of_hand(card)
	card.queue_free()

func sacrifice_card() -> void:
	for card in selected_cards:
		if card.card_data.type != CardData.CardType.NORMAL:
			print("Una de las cartas no es normal, no se puede sacrificar.")
			return
	
	print("Sacrificando cartas...")
	for card in selected_cards:
		player_hand_reference.remove_cards_of_hand(card)
		card.queue_free()
	selected_cards.clear()
