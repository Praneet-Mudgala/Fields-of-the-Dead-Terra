extends Camera2D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_intensity > 0:
		shake_intensity = move_toward(shake_intensity, 0.0, shake_decay * delta)
		offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	else:
		offset = Vector2.ZERO

func start_shake(intensity: float) -> void:
	shake_intensity = intensity
