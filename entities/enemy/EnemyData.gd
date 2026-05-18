extends Resource
class_name EnemyData

@export var enemy_name : String = "Enemy"

@export var max_health : int = 100

@export var heal_amount : int = 20

@export var sprite : Texture2D

@export var moon_phase_turns : Dictionary = {
	Enemy.LunarPhase.NEW_MOON : [
		"ATTACK"
	],

	Enemy.LunarPhase.WAXING_CRESCENT : [
		"ATTACK",
		"DEFEND"
	],

	Enemy.LunarPhase.FIRST_QUARTER : [
		"HEAVY ATTACK"
	],

	Enemy.LunarPhase.WAXING_GIBBOUS : [
		"ATTACK",
		"HEAL"
	],

	Enemy.LunarPhase.FULL_MOON : [
		"HEAVY ATTACK",
		"HEAVY ATTACK"
	],

	Enemy.LunarPhase.WANING_GIBBOUS : [
		"HEAL"
	],

	Enemy.LunarPhase.LAST_QUARTER : [
		"DEFEND",
		"ATTACK"
	],

	Enemy.LunarPhase.WANING_CRESCENT : [
		"ADVANCE MOON"
	]
}
