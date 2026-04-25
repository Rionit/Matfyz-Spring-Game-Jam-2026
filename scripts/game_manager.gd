extends Node

var helpbook_offset : Vector3 = Vector3(1, 0, 0) 

var camera_node : Camera3D

var camera_active : bool = true

var helpbook_selected : bool = false

var selected_document : DocumentController = null

func select_document(doc : DocumentController): 
	if selected_document != null:
		selected_document.put_on_table()
	selected_document = doc
	
