extends Control

func _ready() -> void:
	InputMap.action_erase_events("ui_accept")
	InputMap.action_erase_events("ui_focus_next")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
