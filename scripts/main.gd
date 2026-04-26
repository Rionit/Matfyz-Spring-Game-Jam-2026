extends Node3D

@onready var pauseScene: Node = $PauseMenu
@onready var tutorialScene: Node = $TutorialMenu
@onready var timer = $Timer
var game_manager

@export var time_for_documents: float = 180.0
@export var max_misstakes: int = 10
@export var submission_folder: SubmissionFolder
@export var incoming_folder : Folder
@export var level_1_guis: Array[GUI_3D] = []
@export var level_2_guis: Array[GUI_3D] = []
@export var level_3_guis: Array[GUI_3D] = []
@export var level_4_guis: Array[GUI_3D] = []

var level_1 : Array[DocumentController] = []
var level_2 : Array[DocumentController] = []
var level_3 : Array[DocumentController] = []
var level_4 : Array[DocumentController] = []

@export var testing_folders : bool = false

var pause: bool = false
var tutorial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorialScene.hide()
	pauseScene.hide()
	create_timer()
	game_manager = $'../GameManager'
	game_manager.testing_folders = testing_folders
	var levels_guis = [level_1_guis, level_2_guis, level_3_guis, level_4_guis]
	var levels_docs = [level_1, level_2, level_3, level_4]

	for i in range(4):
		var level_guis = levels_guis[i]
		var level_docs = levels_docs[i]
		for j in range(level_guis.size()):
			var doc = level_guis[j].find_child("Document")
			if doc != null:
				print("Adding " + level_guis[j].name + " to level " + str(i+1))
				level_docs.append(doc)
			else:
				print("ERROR: Document not found in GUI_3D for level " + str(i+1) + " index " + str(j))

	start_timer()
	game_manager.main_game()

	load_level(game_manager.actual_level)
	if game_manager.actual_level == 1:
		show_tutorial()

func _input(event):
	if event.is_action_pressed("pause_action"):
		pause_game()
		
	if event.is_action_pressed("help_action"):
		print("Helpbook input")
		GameManager.helpbook.on_helpbook_input()
		#show_tutorial(tutorial_1)
	if event.is_action_pressed("previous_page"):
		print("Previous page pressed")
		GameManager.helpbook.previous_page()
	if event.is_action_pressed("next_page"):
		print("Next page pressed")
		GameManager.helpbook.next_page()
	if event.is_action_pressed("put_on_table"):
		print("Put on table pressed")
		GameManager.put_on_table()

	

###
# level loading functionality
###
func load_level(level: int = 1) -> void:
	var tutorial_pages: Array[DocumentController] = []
	if level == 1:# and level_1.size() > 0:
		game_manager.load_level(level_1)
		#tutorial_pages = tutorial_1
	elif level == 2 and level_2.size() > 0:
		game_manager.load_level(level_2)
		#tutorial_pages = tutorial_2
	elif level == 3 and level_3.size() > 0:
		game_manager.load_level(level_3)
		#tutorial_pages = tutorial_3
	elif level == 4 and level_4.size() > 0:
		game_manager.load_level(level_4)
		#tutorial_pages = tutorial_4
	else:
		game_over('win')
		return # maybe not needed
	# TODO delete comment, only for testing
	#incoming_folder .add_docs(game_manager.documents_to_submit)
	start_timer()
<<<<<<< HEAD
=======
	show_tutorial()
>>>>>>> main

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
	game_over("timeout")

###
# game over functionality
###
func game_over(reason) -> void:
	if reason == "timeout":
		get_tree().change_scene_to_file("res://scenes/ui/ending.tscn")
	elif reason == "misstakes":
		get_tree().change_scene_to_file("res://scenes/ui/ending.tscn")
	elif reason == "win":
		get_tree().change_scene_to_file("res://scenes/ui/win_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/ending.tscn")

###
# tutorial menu functionality
###
func show_tutorial() -> void:
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
