extends Control

func _ready() -> void:
	InputMap.action_erase_events("ui_accept")
	InputMap.action_erase_events("ui_focus_next")

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credit.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
