extends Node3D

@onready var pauseScene: Node = $PauseMenu
@onready var tutorialScene: Node = $TutorialMenu
@onready var timer = $Timer

var pause: bool = false
var tutorial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorialScene.hide()
	pauseScene.hide()
	create_timer()
	start_timer()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("pause_action"):
		pause_game()

	if event.is_action_pressed("help_action"):
		show_tutorial()

###
# timer functionality
###
func create_timer():
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 3.0

func start_timer():
	timer.start()

func resume_timer():
	timer.set_paused(false)

func stop_timer():
	timer.set_paused(true)

func _on_timer_timeout():
	timer.stop()
	game_over("timeout")

###
# game over functionality
###
func game_over(reason):
	if reason == "timeout":
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

###
# tutorial menu functionality
###
func show_tutorial():
	if pause:
		return
	stop_timer()
	tutorialScene.show()
	tutorial = true

func hide_tutorial():
	if pause:
		return
	resume_timer()
	tutorialScene.hide()
	tutorial = false

func _on_previous_button_pressed() -> void:
	pass # Replace with function body.
	
func _on_next_button_pressed() -> void:
	pass # Replace with function body.

func _on_continue_button_pressed() -> void:
	hide_tutorial()

###
# pause menu functionality
###
func _on_resume_button_pressed() -> void:
	pause_game()

func _on_exit_button_pressed() -> void:
	stop_timer()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func pause_game():
	if tutorial:
		return
	if pause:
		pauseScene.hide()
		resume_timer()
	else:
		pauseScene.show()
		stop_timer()
	pause = !pause
