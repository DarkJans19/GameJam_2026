class_name state_machine extends  Node

#para referenciar el nodo a controlar 
@onready var controlled_node:Node = self.owner

# estado por defecto
@export var default_state:statebasics

# estado actual
var current_state:statebasics = null

func _ready():
	call_deferred("_state_default_start")

func _state_start() -> void:
	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()

func _change_to(new_state:String) -> void:
	if current_state and current_state.has_method("end"):
		current_state.end()
	current_state = get_node(new_state)
	_state_start()
		
func _process(delta: float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)
		
