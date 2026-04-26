extends Control

@onready var buttons_v_box: VBoxContainer = $MarginContainer/VBoxContainer/ButtonsVBox

func _ready() -> void:
	focus_button()

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/credit.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_visbility_changed() -> void:
	if visible:
		focus_button()

func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()
