extends StaticBody3D
class_name Door

@export var required_plates: Array[NodePath] = []

@export_file("PackedScene") var next_level_path: String

var _plate_states := {}

func _ready() -> void:
	for path in required_plates:
		var plate = get_node_or_null(path) as PressurePlate
		if plate == null:
			push_error("Door: could not find plate at %s" % path)
			continue
		_plate_states[plate] = false
		plate.gate_updated.connect(Callable(self, "_on_plate_updated").bind(plate))

	$AnimatedSprite3D.play("closed")
	$CollisionShape3D.disabled = false

	var ta = get_node_or_null("TeleportArea") as Area3D
	if ta:
		ta.body_entered.connect(_on_teleport_body_entered)
	else:
		push_warning("Door: missing TeleportArea; no teleport will occur.")

	print("Door ready; waiting on %d plates…" % _plate_states.size())

func _on_plate_updated(correct_state: bool, plate: PressurePlate) -> void:
	_plate_states[plate] = correct_state
	_update_door_state()

func _update_door_state() -> void:
	if _plate_states.values().has(false):
		$AnimatedSprite3D.play("closed")
		$CollisionShape3D.disabled = false
	else:
		$AnimatedSprite3D.play("opened")
		$CollisionShape3D.disabled = true

func _on_teleport_body_entered(body: Node) -> void:
	if not (body is Player):
		return

	if not $CollisionShape3D.disabled:
		return

	if next_level_path == "":
		push_warning("Door.next_level_path not set – cannot teleport.")
		return

	get_tree().change_scene_to_file(next_level_path)
