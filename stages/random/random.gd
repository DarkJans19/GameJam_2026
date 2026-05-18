extends Control
class_name random

class EventoConfig:
	var titulo: String
	var descripcion: String
	var texto_boton: String
	var tipo_efecto: String
	var peso: int

	func _init(p_titulo: String, p_desc: String, p_boton: String, p_efecto: String, p_peso: int):
		self.titulo = p_titulo
		self.descripcion = p_desc
		self.texto_boton = p_boton
		self.tipo_efecto = p_efecto
		self.peso = p_peso

@onready var descripcion_general: RichTextLabel = $ColorRect/DescripcionGeneral
@onready var boton_accion: Button = $Button

var pool_de_eventos: Array[EventoConfig] = []
var evento_actual: EventoConfig
var fase_resultado: bool = false

func _ready() -> void:
	randomize()
	if not boton_accion.pressed.is_connected(_on_button_pressed):
		boton_accion.pressed.connect(_on_button_pressed)
	_inicializar_pool_eventos()
	_cargar_evento_por_peso()

func _inicializar_pool_eventos() -> void:
	pool_de_eventos.append(EventoConfig.new(
		"NAVE ABANDONADA",
		"En un crater abandonado encuentras una nave alienigena con un material brillante.",
		"Recoger",
		"GANAR_ORO",
		40
	))

	pool_de_eventos.append(EventoConfig.new(
		"Carne alienigena",
		"Encuentras un extraño ser muerto en el suelo... se ve sospechoso",
		"Comer?",
		"CURAR",
		35
	))

	pool_de_eventos.append(EventoConfig.new(
		"Has sido robado",
		"Decides tomar un descanso antes de seguir tu viaje, cuando despiertas ves que se han llevado parte de tus cosas",
		"...",
		"PERDER_ORO",
		20
	))

	pool_de_eventos.append(EventoConfig.new(
		"Carne alienigena",
		"Encuentras un extraño ser muerto en el suelo... se ve sospechoso",
		"Comer?",
		"DAMAGE",
		15
	))

	pool_de_eventos.append(EventoConfig.new(
		"Lunasticio",
		"Vas caminando pero te percatas de un brillo extraño proveniente de la luna",
		"Acercarse",
		"GANAR_CARTA",
		10
	))

	pool_de_eventos.append(EventoConfig.new(
		"Solsticio",
		"Vas caminando pero te percatas de un brillo extraño proveniente del sol",
		"Acercarse",
		"PERDER_CARTA",
		8
	))

func _cargar_evento_por_peso() -> void:
	if pool_de_eventos.is_empty():
		push_error("[Evento Random] El pool de eventos está vacío.")
		return
	
	var peso_total : int = 0
	for evento in pool_de_eventos:
		peso_total += evento.peso
		
	var rng : int = randi_range(1, peso_total)
	var acumulado : int = 0
	
	for evento in pool_de_eventos:
		acumulado += evento.peso
		if rng <= acumulado:
			evento_actual = evento
			break
			
	descripcion_general.clear()
	var texto_formateado = "[center][b]" + evento_actual.titulo + "[/b]\n\n" + evento_actual.descripcion + "[/center]"
	descripcion_general.append_text(texto_formateado)
	
	boton_accion.text = evento_actual.texto_boton

func _on_button_pressed() -> void:
	if fase_resultado:
		get_tree().change_scene_to_file("res://stages/map/map.tscn")
		return

	boton_accion.disabled = true
	var texto_resultado : String = ""

	match evento_actual.tipo_efecto:
		"CURAR":
			var cantidad = _obtener_multiplo_de_5(10, 50)
			game_manager.curar_jugador(cantidad)
			texto_resultado = "La extraña carne te supo horrible, pero sientes una vitalidad renovada.\n\n[color=green](+ " + str(cantidad) + " de Vida)[/color]"
		"DAMAGE":
			var cantidad = _obtener_multiplo_de_5(5, 25)
			game_manager.herir_jugador(cantidad)
			texto_resultado = "Te empieza a doler el estomago de manera terrible. Estaba podrida.\n\n[color=red](- " + str(cantidad) + " de Vida)[/color]"
		"GANAR_ORO":
			var cantidad = _obtener_multiplo_de_5(10, 50)
			game_manager.modificar_oro(cantidad)
			texto_resultado = "Logras desmantelar los restos del motor y extraes recursos valiosos.\n\n[color=yellow](+ " + str(cantidad) + " de Oro)[/color]"
		"PERDER_ORO":
			var cantidad = _obtener_multiplo_de_5(10, 30)
			game_manager.modificar_oro(-cantidad)
			texto_resultado = "Revisas tus bolsillos... Tus sospechas eran ciertas, te falta oro.\n\n[color=orange](- " + str(cantidad) + " de Oro)[/color]"
		"GANAR_CARTA":
			var carta_ganada = _efecto_ganar_carta_aleatoria()
			if carta_ganada != "":
				var nombre_carta = carta_ganada.get_file().get_basename().capitalize()
				texto_resultado = "El haz de luz lunar materializa un nuevo conocimiento en tus manos.\n\n[color=cyan](Ganaste la carta: " + nombre_carta + ")[/color]"
			else:
				texto_resultado = "El destello se desvanece sin interactuar contigo."
		"PERDER_CARTA":
			var carta_perdida = _efecto_perder_carta_aleatoria()
			if carta_perdida != "":
				var nombre_carta = carta_perdida.get_file().get_basename().capitalize()
				texto_resultado = "El intenso calor solar evapora una de tus posesiones del mazo.\n\n[color=magenta](Perdiste la carta: " + nombre_carta + ")[/color]"
			else:
				texto_resultado = "El sol brilla con fuerza pero tu mazo estaba vacio, no perdiste nada."

	descripcion_general.clear()
	var texto_final = "[center][b]" + evento_actual.titulo + "[/b]\n\n" + texto_resultado + "[/center]"
	descripcion_general.append_text(texto_final)

	boton_accion.text = "Siguiente"
	fase_resultado = true
	
	await get_tree().process_frame
	boton_accion.disabled = false

func _obtener_multiplo_de_5(minimo: int, maximo: int) -> int:
	var num = randi_range(minimo, maximo)
	return int(round(num / 5.0)) * 5

func _efecto_ganar_carta_aleatoria() -> String:
	var pool_disponible = game_manager.obtener_cartas_disponibles_para_ganar()
	if pool_disponible.is_empty():
		pool_disponible = game_manager.mazo_jugador
		
	if not pool_disponible.is_empty():
		var carta_random = pool_disponible.pick_random()
		game_manager.agregar_carta_al_mazo(carta_random)
		return carta_random
	return ""

func _efecto_perder_carta_aleatoria() -> String:
	if game_manager.mazo_jugador.is_empty():
		return ""
	var indice_random = randi() % game_manager.mazo_jugador.size()
	var carta_eliminada = game_manager.mazo_jugador[indice_random]
	game_manager.remover_carta_del_mazo(carta_eliminada)
	return carta_eliminada
