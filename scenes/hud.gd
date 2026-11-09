extends Control

@onready var life_label: Label = $LifeLabel
@onready var kills_label: Label = $KillsLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var score_label: Label = $GameOverPanel/ScoreLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton

var kills: int = 0

const SAVE_PATH = "user://highscore.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1.0
	game_over_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	life_label.text = "Lives: 5"
	kills_label.text = "Kills: 0"

func update_lives(amount : int) -> void:
	life_label.text = "Lives: " + str(max(0, amount))

func add_kill() -> void:
	kills += 1
	kills_label.text = "Kills: " + str(kills)

func show_game_over() -> void:
	Engine.time_scale = 0.0
	
	var high_score = load_high_score()
	if kills > high_score:
		high_score = kills
		save_high_score(high_score)
	var display_text = "Kills this round: " + str(kills) + "\nHigh score: " + str(high_score)
	
	if score_label:
		score_label.text = display_text
	
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func save_high_score(score: int) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(score)

func load_high_score() -> int:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			return file.get_32()
	return 0
