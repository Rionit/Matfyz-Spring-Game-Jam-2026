extends Node3D

@onready var pauseScene: Node = $PauseMenu
@onready var tutorialScene: Node = $TutorialMenu

var paused: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorialScene.hide()
	pauseScene.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("pause_action"):
		pause_game()

	if event.is_action_pressed("help_action"):
		tutorialScene.show()
###
# tutorial menu functionality
###
func _on_previous_button_pressed() -> void:
	pass # Replace with function body.
	
func _on_next_button_pressed() -> void:
	pass # Replace with function body.

func _on_continue_button_pressed() -> void:
	tutorialScene.hide()

###
# pause menu functionality
###
func _on_resume_button_pressed() -> void:
	pause_game()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func pause_game():
	if paused:
		pauseScene.hide()
		get_tree().paused = false
	else:
		pauseScene.show()
		get_tree().paused = true
	paused = !paused
