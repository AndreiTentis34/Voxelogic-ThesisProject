extends Area3D
class_name PressurePlate

@export var input_a: int = 0
@export var input_b: int = 0
@export var expected_output: int = 0
@export var required_gate_type: String = "GATE"

var current_box: LogicBox = null
var is_correct: bool = false

signal gate_updated(correct_state: bool)

func _ready() -> void:
	body_entered.connect(self._on_body_entered)
	body_exited.connect(self._on_body_exited)
	_check_gate()

func _on_body_entered(body: Node) -> void:
	if not (body is LogicBox):
		return
	
	if body.gate_type == required_gate_type:
		current_box = body
		_check_gate()

func _on_body_exited(body: Node) -> void:
	if body != current_box:
		return

	current_box = null
	_check_gate()

func _check_gate() -> void:
	if current_box == null:
		is_correct = false
	else:
		var result = current_box.evaluate(input_a, input_b)
		is_correct = (result == expected_output)
	emit_signal("gate_updated", is_correct)
	print("Plate [%s] correct? %s" % [name, is_correct])
