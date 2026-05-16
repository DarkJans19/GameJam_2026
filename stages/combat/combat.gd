extends Node

signal jugador_selecciona_enemigo()
signal ataque_iniciado()
var turno_jugador: bool = true
var puede_abrir_menu: bool = true
var personaje_seleccionado
var personaje_objetivo
var enemigos = []
var turno_enemigo:int = 0
var jugadores = []

func ready():
	enemigos = get_tree().get_nodes_in_group("enemies")
	jugadores = get_tree().get_nodes_in_group("player")
	
func cambiar_turno():
	turno_jugador != turno_jugador
	
func mostrar_seleccion():
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")
	
func establecer_personaje (personaje):
	personaje_seleccionado = personaje
	
func establecer_objetivo (personaje):
	personaje_objetivo = personaje
	
func iniciar_ataque():
	emit_signal("ataque_iniciado")
	personaje_seleccionado.atacar_personaje (personaje_objetivo)
	
func iniciar_turno_enemigo():
	var enemigo_actual = enemigos[turno_enemigo]
	print("Iniciar turno del enenemigo: ", enemigo_actual.name)
	# Funcion atacar
	establecer_personaje (enemigo_actual)
	establecer_objetivo (jugadores.pick_random())
	iniciar_ataque ()
