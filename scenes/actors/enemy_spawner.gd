extends Node2D

const SPECTRE = preload("res://scenes/actors/Enemies/spectre.tscn")
const PYRE = preload("res://scenes/actors/Enemies/pyre.tscn")

@onready var spawn_timer : Timer = $SpawnTimer

var map_min_x = 0.0
var map_max_x = 0.0
var map_min_y = 0.0
var map_max_y = 0.0

var current_wave: int = 1
var enemies_spawned_this_wave: int = 0

@export var base_enemies_per_wave: int = 10
@export var wave_scaling_factor: int = 5
@export var wave_duration: float = 30.0

var is_wave_active: bool = true
var wave_break_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	var background = get_tree().current_scene.find_child("background", true, false)
	if background:
		var bg_pos = background.global_position
		map_min_x = bg_pos.x + 80.0
		map_max_x = bg_pos.x + 640.0 - 80.0
		map_min_y = bg_pos.y + 64.0
		map_max_y = bg_pos.y + 360.0 - 64.0
	
	setup_wave_difficulty()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_wave_active:
		wave_break_timer -= delta
		if wave_break_timer <= 0:
			start_next_wave()

func setup_wave_difficulty() -> void:
	enemies_spawned_this_wave = 0
	
	spawn_timer.wait_time = max(0.2, 1.5 - (current_wave * 0.1))
	spawn_timer.start()
	is_wave_active = true
	print("STARTING WAVE ", current_wave)

func _on_spawn_timer_timeout() -> void:
	if not is_wave_active:
		return
	
	var max_enemies = base_enemies_per_wave + (current_wave - 1) * wave_scaling_factor
	
	if enemies_spawned_this_wave < max_enemies:
		var success = spawn_enemy()
		if success:
			enemies_spawned_this_wave += 1
	else:
		spawn_timer.stop()
		end_current_wave()

func spawn_enemy() -> bool:
	var enemy_container = get_tree().current_scene.get_node_or_null("Enemies")
	
	if not enemy_container:
		return false
	
	var enemy_pool = [SPECTRE, PYRE]
	var random_enemy_scene = enemy_pool[randi() % enemy_pool.size()]
	
	var new_enemy = random_enemy_scene.instantiate()
	
	randomize()
	
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	var border_buffer: float = 32.0
	
	match side:
		0: #top
			spawn_pos.x = randf_range(0.0, 640.0)
			spawn_pos.y = -border_buffer
		1: #bottom
			spawn_pos.x = randf_range(0.0, 640.0)
			spawn_pos.y = 360.0 + border_buffer
		2: #left
			spawn_pos.x = -border_buffer
			spawn_pos.y = randf_range(0.0, 360.0)
		3: #right
			spawn_pos.x = 640 + border_buffer
			spawn_pos.y = randf_range(0.0, 360.0)
	enemy_container.add_child(new_enemy)
	new_enemy.global_position = spawn_pos
	return true


func end_current_wave() -> void:
	is_wave_active = false
	wave_break_timer = 5.0
	print("Wave complete! Next wave starts in 5 seconds...")

func start_next_wave() -> void:
	current_wave += 1
	setup_wave_difficulty()
