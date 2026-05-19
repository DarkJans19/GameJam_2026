extends Resource
class_name EnemyData

@export var enemy_name : String 

@export var max_health : int

@export var heal_amount : int

@export var damage : int

@export var heavy_damage : int

@export var sprite : Texture2D

@export var hurt_audio: AudioStream

@export var attack_audio: AudioStream

@export var intro_audio: AudioStream

@export var moon_phase_turns : Dictionary = {
	CombatManager.LunarPhase.NEW_MOON : [
		"ATTACK"
	],

	CombatManager.LunarPhase.WAXING_CRESCENT : [
		"ATTACK",
		"DEFEND"
	],

	CombatManager.LunarPhase.FIRST_QUARTER : [
		"HEAVY ATTACK"
	],

	CombatManager.LunarPhase.WAXING_GIBBOUS : [
		"ATTACK",
		"HEAL"
	],

	CombatManager.LunarPhase.FULL_MOON : [
		"HEAVY ATTACK",
		"HEAVY ATTACK"
	],

	CombatManager.LunarPhase.WANING_GIBBOUS : [
		"HEAL"
	],

	CombatManager.LunarPhase.LAST_QUARTER : [
		"DEFEND",
		"ATTACK"
	],

	CombatManager.LunarPhase.WANING_CRESCENT : [
		"ADVANCE MOON"
	]
}
