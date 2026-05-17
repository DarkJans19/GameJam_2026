class_name StateMachine extends Node

@onready var controlled_node: Node = self.owner

@export var default_state: statebasics

var current_state: statebasics = null

func _ready():
	call_deferred("_state_default_start")


func _state_default_start() -> void:
	if default_state:
		current_state = default_state
		_state_start()
	else:
		push_error("No se ha asignado un 'default_state' en la Máquina de Estados: ", self.name)


func _state_start() -> void:
	if current_state:
		current_state.controlled_node = controlled_node
		current_state.state_machine = self
		current_state.start()


func _change_to(new_state: String) -> void:
	if current_state and current_state.has_method("end"):
		current_state.end()
	
	current_state = get_node(new_state)
	_state_start()


func _process(delta: float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)
