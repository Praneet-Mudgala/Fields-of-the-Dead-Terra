extends Area2D

const PARTICLES_SCENE = preload("res://scenes/actors/impact_particles.tscn")

@export var speed: float = 200.0
var direction: Vector2 = Vector2.UP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	get_tree().create_timer(3.0).timeout.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation += 15.0 * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("enemy_take_damage"):
		body.enemy_take_damage()
		var effects = PARTICLES_SCENE.instantiate()
		effects.global_position = global_position
		get_tree().current_scene.add_child(effects)
		queue_free()
	elif body is StaticBody2D:
		var effects = PARTICLES_SCENE.instantiate()
		effects.global_position = global_position
		get_tree().current_scene.add_child(effects)
		queue_free()
		

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("enemy_take_damage"):
		area.enemy_take_damage()
		var effects = PARTICLES_SCENE.instantiate()
		effects.global_position = global_position
		get_tree().current_scene.add_child(effects)
		queue_free()
