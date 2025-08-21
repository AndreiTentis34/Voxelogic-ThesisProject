extends CharacterBody3D
class_name Player
const FLOOR_NORMAL = Vector3.UP
@export var walk_speed: float = 7.0
@export var push_speed: float = 5.0
@export var gravity:    float = 30.0
@export var jump_force: float = 12.0
@onready var sprite3d:        AnimatedSprite3D = $Marker3D/Sprite3D
@onready var hair_sprite3d:   AnimatedSprite3D = $Marker3D/Hair
@onready var outfit_sprite3d: AnimatedSprite3D = $Marker3D/Outfit
@onready var push_detect:     Area3D           = $PushDetect
var facing := "down"
var overlapping_boxes: Array = []
var target_box: CharacterBody3D = null

func _ready() -> void:
	up_direction = FLOOR_NORMAL
	push_detect.monitoring = true
	push_detect.body_entered.connect(_on_body_entered)
	push_detect.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D and body.has_method("apply_push"):
		overlapping_boxes.append(body)

func _on_body_exited(body: Node) -> void:
	overlapping_boxes.erase(body)

func _physics_process(delta: float) -> void:
	if target_box and not overlapping_boxes.has(target_box):
		target_box = null

	if Input.is_action_just_pressed("push") and overlapping_boxes.size() > 0:
		target_box = overlapping_boxes[0]
	elif Input.is_action_just_released("push"):
		target_box = null

	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down")  - Input.get_action_strength("move_up")
	).normalized()

	if target_box and Input.is_action_pressed("push") and input_dir != Vector2.ZERO and is_on_floor() and target_box.is_on_floor():
		var dir3 = Vector3(input_dir.x, 0, input_dir.y).normalized() * push_speed

		var rel = (global_transform.origin - target_box.global_transform.origin).normalized()
		var side = _get_side(rel)

		var is_along_x = abs(dir3.x) > abs(dir3.z)
		var act: String
		if (side in ["left","right"] and not is_along_x) or (side in ["up","down"] and is_along_x):
			act = "pull"
		else:
			var to_box = (target_box.global_transform.origin - global_transform.origin).normalized()
			act = "push" if to_box.dot(dir3) > 0 else "pull"

		var anim_side
		if act == "push":
			if abs(dir3.x) > abs(dir3.z):
				anim_side = "right" if dir3.x > 0 else "left"
			else:
				anim_side = "down" if dir3.z > 0 else "up"
		else:
			anim_side = _invert_side(side)

		var action_anim = "%s_%s" % [act, anim_side]

		target_box.apply_push(dir3)
		velocity.x = dir3.x
		velocity.z = dir3.z

		move_and_slide()
		sprite3d.play(action_anim)
		hair_sprite3d.play(action_anim)
		outfit_sprite3d.play(action_anim)
		return

	velocity.x = input_dir.x * walk_speed
	velocity.z = input_dir.y * walk_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	if input_dir != Vector2.ZERO:
		if abs(input_dir.x) > abs(input_dir.y):
			facing = "right" if input_dir.x > 0 else "left"
		else:
			facing = "down" if input_dir.y > 0 else "up"

	var anim_name := ""
	if not is_on_floor():
		anim_name = "jump_%s" % facing
	elif input_dir != Vector2.ZERO:
		anim_name = "walk_%s" % facing
	else:
		anim_name = "idle_%s" % facing

	move_and_slide()
	sprite3d.play(anim_name)
	hair_sprite3d.play(anim_name)
	outfit_sprite3d.play(anim_name)

func _get_side(rel: Vector3) -> String:
	if abs(rel.x) > abs(rel.z):
		return "right" if rel.x > 0 else "left"
	else:
		return "down" if rel.z > 0 else "up"

func _invert_side(side: String) -> String:
	match side:
		"left":  return "right"
		"right": return "left"
		"up":    return "down"
		"down":  return "up"
		_:       return side
