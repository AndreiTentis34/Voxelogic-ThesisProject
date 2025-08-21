extends Node3D

@onready var hint_box  : Panel  = $UI/HintBox
@onready var trip_wire : Area3D = $UI/TripWire

func _ready() -> void:
	hint_box.visible = true
	trip_wire.body_entered.connect(Callable(self, "_on_trip_wire_body_entered"))

func _on_trip_wire_body_entered(body: Node) -> void:
	if body is Player and hint_box.visible:
		hint_box.visible = false
