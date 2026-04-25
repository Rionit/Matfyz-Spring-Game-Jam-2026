extends Node

var helpbook_offset : Vector3 = Vector3(1, 0, 0) 

var camera_node : Camera3D

var player_face : Node3D # Where the selected documents will be reparented

var table_object : Node3D # Where the documents will be placed when put on the table

var camera_active : bool = true

var helpbook_selected : bool = false

# TODO: Add helpbook
var helpbook : Node3D

var selected_document : DocumentController = null

func select_document(doc : DocumentController): 
	if selected_document != null:
		put_on_table()

	doc.select()
	selected_document = doc

func _ready() -> void:
	camera_node = $'../Main/MainCamera'
	player_face = $'../Main/PlayerFace'
	table_object = $'../Main/TableObject'
	helpbook = $'../Main/Helpbook'

func put_on_table():
	if selected_document != null:
		selected_document.move_parent.set_parent(table_object)
		selected_document.put_on_table()
		selected_document = null
func move_to_top():
	if selected_document != null:
		selected_document.move_parent.set_parent(player_face)
		selected_document.move_to_top()
	# if helpbook_selected:
	# helpbook.move_to_top()

func move_from_top():
	if selected_document != null:
		selected_document.move_parent.set_parent(table_object)
		selected_document.move_from_top()