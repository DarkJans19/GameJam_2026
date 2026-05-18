extends Node

signal vida_cambiada(actual: int, maxima: int)
signal oro_cambiado(nuevo_total: int)
signal mazo_actualizado(nuevo_tamano: int)

var vida_max_jugador : int = 100
var vida_actual_jugador : int = 100
var oro : int = 50

var mazo_jugador : Array[String] = [
	"res://entities/player/cards/card/lunar_cards/Antonio.tres",
	"res://entities/player/cards/card/lunar_cards/glerp_y_glop.tres",
	"res://entities/player/cards/card/lunar_cards/menguantes.tres",
	"res://entities/player/cards/card/lunar_cards/Salomon.tres",
	"res://entities/player/cards/card/normal_cards/daño.tres",
	"res://entities/player/cards/card/normal_cards/escudo.tres",
	"res://entities/player/cards/card/normal_cards/vida.tres",
	"res://entities/player/cards/card/comodin_cards/luna_llena.tres",
	"res://entities/player/cards/card/comodin_cards/luna_nueva.tres",
]

var todas_las_cartas_del_juego : Array[String] = [
	"res://entities/player/cards/card/lunar_cards/Antonio.tres",
	"res://entities/player/cards/card/lunar_cards/glerp_y_glop.tres",
	"res://entities/player/cards/card/lunar_cards/jimbo.tres",
	"res://entities/player/cards/card/lunar_cards/joaquin.tres",
	"res://entities/player/cards/card/lunar_cards/lasper.tres",
	"res://entities/player/cards/card/lunar_cards/lorang.tres",
	"res://entities/player/cards/card/lunar_cards/mago_marino.tres",
	"res://entities/player/cards/card/lunar_cards/menguantes.tres",
	"res://entities/player/cards/card/lunar_cards/Salomon.tres",
	"res://entities/player/cards/card/comodin_cards/luna_llena.tres",
	"res://entities/player/cards/card/comodin_cards/luna_nueva.tres",
]

var cartas_bloqueadas_actualmente : Array[String] = []

var etapa_combate_actual : int = 0
var current_event : int = 0
var last_selected_event : String = ""

func reset_progress() -> void:
	vida_max_jugador = 100
	vida_actual_jugador = 100
	oro = 50
	current_event = 0
	last_selected_event = ""
	etapa_combate_actual = 0
	
	mazo_jugador = [
		"res://entities/player/cards/card/lunar_cards/Antonio.tres",
		"res://entities/player/cards/card/lunar_cards/glerp_y_glop.tres",
		"res://entities/player/cards/card/lunar_cards/menguantes.tres",
		"res://entities/player/cards/card/lunar_cards/Salomon.tres",
	]
	
	vida_cambiada.emit(vida_actual_jugador, vida_max_jugador)
	oro_cambiado.emit(oro)
	mazo_actualizado.emit(mazo_jugador.size())

func curar_jugador(cantidad: int) -> void:
	vida_actual_jugador = clampi(vida_actual_jugador + cantidad, 0, vida_max_jugador)
	vida_cambiada.emit(vida_actual_jugador, vida_max_jugador)
	print("[GameManager] Jugador curado. Vida actual: ", vida_actual_jugador, "/", vida_max_jugador)

func aplicar_damage_jugador(cantidad: int) -> void:
	vida_actual_jugador = clampi(vida_actual_jugador - cantidad, 0, vida_max_jugador)
	vida_cambiada.emit(vida_actual_jugador, vida_max_jugador)
	print("[GameManager] Jugador recibe daño puro: -", cantidad, " | Vida restante: ", vida_actual_jugador, "/", vida_max_jugador)
	
	if vida_actual_jugador <= 0:
		_procesar_derrota_global()

func modificar_oro(cantidad: int) -> void:
	oro = max(0, oro + cantidad)
	oro_cambiado.emit(oro)
	print("[GameManager] Balance de oro actualizado: ", oro, "g (Cambio: ", cantidad, ")")

func procesar_victoria_combate(cantidad_enemigos: int) -> void:
	var oro_base : int = 0
	match etapa_combate_actual:
		0: oro_base = randi_range(10, 20)
		1: oro_base = randi_range(25, 40)
		2: oro_base = randi_range(45, 65)
		3: oro_base = randi_range(100, 150)
		
	var oro_ganado = oro_base + (cantidad_enemigos * 5)
	modificar_oro(oro_ganado)

func obtener_cartas_disponibles_para_ganar() -> Array[String]:
	var disponibles : Array[String] = []
	for carta in todas_las_cartas_del_juego:
		if not cartas_bloqueadas_actualmente.has(carta):
			disponibles.append(carta)
	return disponibles

func agregar_carta_al_mazo(ruta_carta: String) -> void:
	if ResourceLoader.exists(ruta_carta):
		mazo_jugador.append(ruta_carta)
		mazo_actualizado.emit(mazo_jugador.size())
		print("[GameManager] Carta añadida con éxito: ", ruta_carta)
	else:
		push_error("[GameManager] Error: No existe un recurso de carta en la ruta: " + ruta_carta)

func remover_carta_del_mazo(ruta_carta: String) -> bool:
	if mazo_jugador.has(ruta_carta):
		mazo_jugador.erase(ruta_carta)
		mazo_actualizado.emit(mazo_jugador.size())
		print("[GameManager] Carta removida del mazo: ", ruta_carta)
		return true
	return false

func _procesar_derrota_global() -> void:
	print("[GameManager] Fin de la partida: La vida del jugador ha llegado a cero.")
	reset_progress()
	get_tree().change_scene_to_file("res://stages/menu/menu.tscn")
