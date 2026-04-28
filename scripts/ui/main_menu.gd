extends Control

@onready var click: AudioStreamPlayer2D = $Click
@onready var hover: AudioStreamPlayer2D = $Hover
@onready var credit: Control = $Credit

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	click.play()

func _on_credit_button_pressed() -> void:
	click.play()
	credit.show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	click.play()

func _on_button_hover() -> void:
	hover.play()
