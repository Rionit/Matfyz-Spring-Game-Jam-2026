# main_menu.gd
extends Control

@onready var buttons_v_box: VBoxContainer = $MarginContainer/VBoxContainer/ButtonsVBox
var main_menu_scene = preload("res://scenes/ui/main_menu.tscn")

func _ready() -> void:
	print('credit')
	focus_button()

func _on_back_button_pressed() -> void:
	print('credit')
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_visbility_changed() -> void:
	if visible:
		focus_button()

func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()
