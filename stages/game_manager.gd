extends Node

var vida_max_jugador : int = 100
var vida_actual_jugador : int = 100
var oro : int = 50

var mazo_jugador : Array[String] = [
	"res://entities/player/cards/card/especific_cards/caballo_bandera.tres",
	"res://entities/player/cards/card/especific_cards/cabeza_alien.tres",
	"res://entities/player/cards/card/especific_cards/doble_alien.tres",
	"res://entities/player/cards/card/especific_cards/guantes.tres"
]

var todas_las_cartas_del_juego : Array[String] = [
	"res://entities/player/cards/card/especific_cards/caballo_bandera.tres",
	"res://entities/player/cards/card/especific_cards/cabeza_alien.tres",
	"res://entities/player/cards/card/especific_cards/doble_alien.tres",
	"res://entities/player/cards/card/especific_cards/guantes.tres",
	"res://entities/player/cards/card/especific_cards/jimbo.tres",
	"res://entities/player/cards/card/especific_cards/joaquin.tres",
	"res://entities/player/cards/card/especific_cards/lobo_fantasma.tres",
	"res://entities/player/cards/card/especific_cards/mosquito_magico.tres",
	"res://entities/player/cards/card/especific_cards/naranja_medieval.tres",
	"res://entities/player/cards/card/especific_cards/ratastronauta.tres"
]

var cartas_bloqueadas_actualmente : Array[String] = [
	"res://entities/player/cards/card/especific_cards/lobo_fantasma.tres",
	"res://entities/player/cards/card/especific_cards/joaquin.tres"
]

var current_event : int = 0
var last_selected_event : String = ""
var etapa_combate_actual : int = 0

func reset_progress() -> void:
	current_event = 0
	last_selected_event = ""
	vida_actual_jugador = vida_max_jugador
	oro = 50
	mazo_jugador = [
		"res://entities/player/cards/card/especific_cards/caballo_bandera.tres",
		"res://entities/player/cards/card/especific_cards/cabeza_alien.tres",
		"res://entities/player/cards/card/especific_cards/doble_alien.tres",
		"res://entities/player/cards/card/especific_cards/guantes.tres"
	]
	print("[GameManager] Progreso, economía y mazo inicial reiniciados por completo.")

func herir_jugador(cantidad: int) -> void:
	vida_actual_jugador -= cantidad
	print("[GameManager] Jugador herido en ", cantidad, ". Vida actual: ", vida_actual_jugador)
	if vida_actual_jugador <= 0:
		vida_actual_jugador = 0
		print("[GameManager] Jugador derrotado. Volviendo al menú principal.")
		reset_progress()
		get_tree().change_scene_to_file("res://stages/menu/menu.tscn")

func curar_jugador(cantidad: int) -> void:
	vida_actual_jugador = clampi(vida_actual_jugador + cantidad, 0, vida_max_jugador)
	print("[GameManager] Jugador curado en ", cantidad, ". Vida actual: ", vida_actual_jugador)

func modificar_oro(cantidad: int) -> void:
	oro = max(0, oro + cantidad)
	print("[GameManager] Oro modificado en ", cantidad, ". Oro actual: ", oro)

func procesar_victoria_combate(cantidad_enemigos: int) -> void:
	var oro_base : int = 0
	
	match etapa_combate_actual:
		0: oro_base = randi_range(10, 20)
		1: oro_base = randi_range(25, 40)
		2: oro_base = randi_range(45, 65)
		3: oro_base = randi_range(100, 150)
		
	var bono_enemigos = cantidad_enemigos * 5
	var oro_ganado = oro_base + bono_enemigos
	
	modificar_oro(oro_ganado)
	print("[GameManager] ¡Combate ganado! Total recibido: +", oro_ganado, " de oro.")

func obtener_cartas_disponibles_para_ganar() -> Array[String]:
	var disponibles : Array[String] = []
	for carta in todas_las_cartas_del_juego:
		if not cartas_bloqueadas_actualmente.has(carta):
			disponibles.append(carta)
	return disponibles

func agregar_carta_al_mazo(ruta_carta: String) -> void:
	if ResourceLoader.exists(ruta_carta):
		mazo_jugador.append(ruta_carta)
		print("[GameManager] Carta añadida con éxito: ", ruta_carta)
		print("Total de cartas en el mazo: ", mazo_jugador.size())
	else:
		push_error("[GameManager] Error: No existe un recurso de carta en la ruta: " + ruta_carta)

func remover_carta_del_mazo(ruta_carta: String) -> bool:
	if mazo_jugador.has(ruta_carta):
		mazo_jugador.erase(ruta_carta)
		print("[GameManager] Carta removida con éxito: ", ruta_carta)
		print("Total de cartas en el mazo: ", mazo_jugador.size())
		return true
	
	print("[GameManager] Advertencia: Se intentó remover una carta que no estaba en el mazo.")
	return false

func cambiar_mazo_completo(nuevo_mazo: Array[String]) -> void:
	mazo_jugador = nuevo_mazo
	print("[GameManager] Mazo reescrito por completo. Nueva cantidad: ", mazo_jugador.size())
