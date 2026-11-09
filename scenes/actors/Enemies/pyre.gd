extends Area2D

@export var health: int = 1
@export var speed: float = 90.0
@export var damage: float = 1.0

var is_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var player = get_tree().current_scene.find_child("Player", true, false)
	
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		if is_active:
			global_position += direction * speed * delta
			$AnimatedSprite2D.look_at(player.global_position)
			$AnimatedSprite2D.play("Idle")

func enemy_take_damage() -> void:
	health -= 1
	if health <= 0:
		var hud = get_tree().current_scene.find_child("HUD", true, false)
		if hud:
			hud.add_kill()
		is_active = false
		$AnimatedSprite2D.play("Death")
		await $AnimatedSprite2D.animation_finished
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
