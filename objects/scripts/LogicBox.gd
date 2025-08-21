extends CharacterBody3D
class_name LogicBox

@export var gravity: float = 30.0
var being_pushed := false

func _physics_process(delta: float) -> void:
	if not being_pushed:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0

	move_and_slide()

	if not being_pushed:
		velocity.x = 0
		velocity.z = 0

	being_pushed = false

func apply_push(dir: Vector3) -> void:
	if is_on_floor():
		being_pushed = true
		velocity.x = dir.x
		velocity.z = dir.z

@export var gate_type: String = "GATE"

func evaluate(a: int, b: int) -> int:
	push_warning("Box.evaluate() not overridden on %s" % name)
	return 0
