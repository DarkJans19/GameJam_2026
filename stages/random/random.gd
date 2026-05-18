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
		"Un mercader interestelar te ofrece una sustancia viscosa que cura heridas.",
		"Comer",
		"CURAR_JUGADOR",
		30
	))

	pool_de_eventos.append(EventoConfig.new(
		"TORMENTA SOLAR",
		"Una radiacion golpea tus sistemas de almacenamiento de cartas.",
		"Resistir",
		"PERDER_CARTA",
		30
	))

func _cargar_evento_por_peso() -> void:
	var total_peso = 0
	for ev in pool_de_eventos:
		total_peso += ev.peso

	var rng = randi_range(1, total_peso)
	var ac = 0
	for ev in pool_de_eventos:
		ac += ev.peso
		if rng <= ac:
			evento_actual = ev
			break

	_mostrar_evento_inicial()

func _mostrar_evento_inicial() -> void:
	descripcion_general.clear()
	var texto = "[center][b]" + evento_actual.titulo + "[/b]\n\n" + evento_actual.descripcion + "[/center]"
	descripcion_general.append_text(texto)
	boton_accion.text = evento_actual.texto_boton

func _on_button_pressed() -> void:
	if fase_resultado:
		get_tree().change_scene_to_file("res://stages/map/map.tscn")
		return

	boton_accion.disabled = true
	_procesar_efecto_evento()

func _procesar_efecto_evento() -> void:
	var texto_resultado = ""

	match evento_actual.tipo_efecto:
		"GANAR_ORO":
			var cantidad = _obtener_multiplo_de_5(15, 35)
			game_manager.modificar_oro(cantidad)
			texto_resultado = "Encuentras chatarra espacial valiosa.\n\n[color=yellow](+ " + str(cantidad) + " de oro)[/color]"

		"CURAR_JUGADOR":
			var cantidad = _obtener_multiplo_de_5(20, 40)
			game_manager.curar_jugador(cantidad)
			texto_resultado = "Tus nanocitos reparan parte del chasis dañado.\n\n[color=green](+ " + str(cantidad) + " de HP)[/color]"

		"PERDER_CARTA":
			if not game_manager.mazo_jugador.is_empty():
				var carta_perdida = game_manager.mazo_jugador.pick_random()
				var nombre_carta = carta_perdida.get_file().get_basename().capitalize()
				game_manager.remover_carta_del_mazo(carta_perdida)
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
