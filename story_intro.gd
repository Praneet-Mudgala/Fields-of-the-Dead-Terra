extends Control

var slides: Array = [
	# Preload the story panels here
	preload("res://assets/art/storypanel1.png"),
	preload("res://assets/art/storypanel2.png")
]

var current_slide_index : int = 0
@onready var slide_display: TextureRect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if slides.size() > 0:
		slide_display.texture = slides[current_slide_index]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance_slide()

func advance_slide() -> void:
	current_slide_index += 1
	if current_slide_index < slides.size():
		slide_display.texture = slides[current_slide_index]
	else:
		start_game()

func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
