extends Button

func _ready() -> void:
	connect("pressed", Callable(self, "_on_reset_pressed"))

func _on_reset_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
