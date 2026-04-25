extends Control

@export var select_button : Button
@export var put_on_table_button : Button
@export var stash_button : Button
@export var list_button : Button

@export var document : DocumentController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select_button.pressed.connect(func():GameManager.select_document(document))
	put_on_table_button.pressed.connect(func():GameManager.put_on_table())
	stash_button.pressed.connect(func():GameManager.move_to_folder_test(document))
	list_button.pressed.connect(func():GameManager.move_to_list_test(document))
