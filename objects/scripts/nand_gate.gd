extends "res://objects/scripts/LogicBox.gd"
class_name nand_gate

func _ready() -> void:
	gate_type = "GATE"

func evaluate(a: int, b: int) -> int:
	return !(a and b)
