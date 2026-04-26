extends Node3D

@onready var pauseScene: Node = $PauseMenu
@onready var tutorialScene: Node = $TutorialMenu
@onready var timer = $Timer
var game_manager

@export var time_for_documents: float = 180.0
@export var max_misstakes: int = 10
@export var submission_folder: SubmissionFolder
@export var incomming_folder: Folder
@export var level_1: Array[DocumentController] = []
@export var level_2: Array[DocumentController] = []
@export var level_3: Array[DocumentController] = []
@export var level_4: Array[DocumentController] = []
@export var tutorial_1: Array[DocumentController] = []
@export var tutorial_2: Array[DocumentController] = []
@export var tutorial_3: Array[DocumentController] = []
@export var tutorial_4: Array[DocumentController] = []

var pause: bool = false
var tutorial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorialScene.hide()
	pauseScene.hide()
	create_timer()
	game_manager = $'../GameManager'
	game_manager.main_game()
	load_level(game_manager.actual_level)

func _input(event):
	if event.is_action_pressed("pause_action"):
		pause_game()

	if event.is_action_pressed("help_action"):
		#TODO place for helpbook call
		show_tutorial(tutorial_1)

###
# level loading functionality
###
func load_level(level: int = 1) -> void:
	var tutorial_pages: Array[DocumentController] = []
	if level == 1:# and level_1.size() > 0:
		game_manager.load_level(level_1)
		tutorial_pages = tutorial_1
	elif level == 2 and level_2.size() > 0:
		game_manager.load_level(level_2)
		tutorial_pages = tutorial_2
	elif level == 3 and level_3.size() > 0:
		game_manager.load_level(level_3)
		tutorial_pages = tutorial_3
	elif level == 4 and level_4.size() > 0:
		game_manager.load_level(level_4)
		tutorial_pages = tutorial_4
	else:
		game_over('win')
		return # maybe not needed
	# TODO delete comment, only for testing
	#incomming_folder.add_docs(game_manager.documents_to_submit)
	start_timer()
	show_tutorial(tutorial_pages)

func submit_day() -> void:
	game_manager.evaluate_day()
	game_manager.next_level()
	load_level(game_manager.actual_level)

###
# timer functionality
###
func create_timer() -> void:
	timer.timeout.connect(_on_timer_timeout)

func start_timer() -> void:
	timer.wait_time = time_for_documents
	timer.start()

func resume_timer() -> void:
	timer.set_paused(false)

func stop_timer() -> void:
	timer.set_paused(true)

func _on_timer_timeout() -> void:
	timer.stop()
	timer.timeout.disconnect()
	game_over("timeout")

###
# game over functionality
###
func game_over(reason) -> void:
	if reason == "timeout":
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	if reason == "misstakes":
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	if reason == "win":
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

###
# tutorial menu functionality
###
func show_tutorial(tutorial_pages: Array[DocumentController]) -> void:
	if pause:
		return
	stop_timer()
	# TODO add helpboook pages
	#tutorialScene... tutorial_pages
	tutorialScene.show()
	tutorial = true

func hide_tutorial() -> void:
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

func pause_game() -> void:
	if tutorial:
		return
	if pause:
		pauseScene.hide()
		resume_timer()
	else:
		pauseScene.show()
		stop_timer()
	pause = !pause
