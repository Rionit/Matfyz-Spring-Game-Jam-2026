extends Node

var helpbook_offset : Vector3 = Vector3(0.1, 0, 0) 

var camera_node : MainCamera

var player_face : Node3D # Where the selected documents will be reparented

var table_object : Node3D # Where the documents will be placed when put on the table

var camera_active : bool = true

var helpbook_selected : bool = false

@export var test_folder :Node3D # Position where documents will be stashed when moved to folder (relative to player face)

@export var test_folder_list : Node3D

@export var testing_folders : bool = false

# TODO: Add helpbook
var helpbook : Node3D

var selected_document : DocumentController = null

var max_misstakes : int

var max_misstakes_from_main : int

var actual_level : int = 1

## new documents, not submitted documents from previous day, recurent documents
var documents_to_submit : Array[DocumentController] = []

var main : Node = null

func main_game() -> void:
	main = $'../Main'
	max_misstakes_from_main = main.max_misstakes
	max_misstakes = max_misstakes_from_main

	camera_node = $'../Main/MainCamera'
	player_face = $'../Main/MainCamera/PlayerFace'
	table_object = $'../Main/TableObject'

	if testing_folders:
		test_folder = $'../Main/TableObject/TestFolder'
		test_folder_list = $'../Main/TableObject/TestList'

	#helpbook = $'../Main/Helpbook'

func select_document(doc : DocumentController): 
	if selected_document != null:
		put_on_table()

	if doc.folder != null:
		doc.folder.remove_reorder(doc)
	
	doc.select()
	selected_document = doc

func put_on_table():
	if selected_document != null:
		selected_document.put_on_table()
		selected_document = null

func move_to_top():
	if selected_document != null:
		selected_document.move_to_top()
	# if helpbook_selected:
	# 	helpbook.move_to_top()

func move_from_top():
	if selected_document != null:
		selected_document.move_from_top()
	# if helpbook_selected:
	# 	helpbook.move_from_top()

func move_to_folder_test(document : DocumentController):
	document.stash(test_folder.position)

func move_to_list_test(document : DocumentController):
	document.list(test_folder.position, test_folder_list.position)

func load_level(docs: Array[DocumentController]) ->void:
	for i in docs:
		documents_to_submit.append(i)

func evaluate_day():
	max_misstakes = max_misstakes_from_main
	var misstakes = main.submission_folder.evaluate(documents_to_submit)
	max_misstakes -= misstakes
	if max_misstakes <= 0:
		main.game_over('misstakes')
	var missing_documents = main.submission_folder.missing(documents_to_submit)
	documents_to_submit = []
	for i in missing_documents:
		documents_to_submit.append(i)

func next_level() -> void:
	actual_level += 1
	
