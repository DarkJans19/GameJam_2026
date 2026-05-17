extends Node2D 
class_name Enemy

@export var data: EnemyData

var current_health: int
var current_shield: int

func _ready() -> void:
	add_to_group("Enemies")
	
	# Hay que asignar el resto de datos al nodo
	if data:
		current_health = data.max_health
		current_shield = data.starting_shield


func recibir_dano(cantidad: int) -> void:
	if current_shield >= 0 and cantidad < current_shield:
		current_shield -= cantidad
		print(data.enemy_name, " recibió ", cantidad, " de daño. Escudo: ", current_shield)
	elif current_shield >= 0 and cantidad >= current_shield:
		var extra_damage = cantidad - current_shield
		current_health -= extra_damage
		print(data.enemy_name, " recibió ", cantidad, " de daño. Vida: ", current_health)
	if current_health <= 0:
		queue_free() # Muere

func curarse(cantidad: int) -> void:
	current_health += cantidad
	if current_health > data.max_health:
		current_health = data.max_health
