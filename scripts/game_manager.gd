extends Node

var helpbook_offset : Vector3 = Vector3(1, 0, 0) 

var camera_node : Camera3D

var camera_active : bool = true

var helpbook_selected : bool = false

var selected_document : DocumentController = null

var max_misstakes : int
var max_misstakes_from_main : int

## new documents, not submitted documents from previous day, recurent documents
var documents_to_submit : Array[DocumentController] = []

var main : Node = null

func main_game() -> void:
	main = $'../Main'
	max_misstakes_from_main = main.max_misstakes
	max_misstakes = max_misstakes_from_main

func select_document(doc : DocumentController): 
	if selected_document != null:
		selected_document.put_on_table()
	selected_document = doc
	





func evaluate_day():
	max_misstakes = max_misstakes_from_main
	var misstakes = main.submission_folder.evaluate(documents_to_submit)
	max_misstakes -= misstakes
	if max_misstakes <= 0:
		main.game_over('misstakes')
