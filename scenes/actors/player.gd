extends CharacterBody2D
#The child player
const BULLET_SCENE = preload("res://scenes/actors/bullet.tscn")

var speed : int
var screen_size : Vector2
var can_shoot : bool = true
var is_dead: bool = false
var is_damage: bool = false

@export var health: int = 5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var muzzle: Marker2D = $WeaponPivot/Gun/Tip
@onready var shoot_cooldown: Timer = $ShootCooldown

func _ready() -> void:
	global_position = Vector2(320.0, 180.0)
	speed = 200
	screen_size = get_viewport_rect().size

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)



func _physics_process(_delta):
	if is_dead:
		return
	
	if not is_damage or is_dead:
		if sprite.animation != "Damage" or "Death":
			if velocity.length() > 0:
				sprite.play("Walk")
			else:
				sprite.play("Idle")
	
	if is_dead:
		sprite.play("Death")
	
	get_input()
	move_and_slide()
	
	
	var mouse_pos = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)
	
	if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("ui_accept"):
		if can_shoot:
			shoot_projectile()


func shoot_projectile() -> void:
	can_shoot = false
	
	var bullet_instance = BULLET_SCENE.instantiate()
	
	bullet_instance.global_position = muzzle.global_position
	
	var target_dir = (get_global_mouse_position() - muzzle.global_position).normalized()
	bullet_instance.direction = target_dir
	bullet_instance.rotation = target_dir.angle()
	
	get_tree().current_scene.add_child(bullet_instance)
	
	shoot_cooldown.start()
	shoot_cooldown.timeout.connect(func(): can_shoot = true)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	is_damage = true
	
	var camera = get_tree().current_scene.find_child("Camera2D", true, false)
	if camera:
		camera.start_shake(5.0)
	health -= amount
	print("Ouch! You took damage. Remaining lives: ", health)
	var hud = get_tree().current_scene.find_child("HUD",  true, false)
	if hud:
		hud.update_lives(health)
	
	sprite.play("Damage")
	await sprite.animation_finished
	is_damage = false
	
	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	sprite.play("Death")
	
	var hud = get_tree().current_scene.find_child("HUD", true, false)
	if hud:
		hud.show_game_over()
