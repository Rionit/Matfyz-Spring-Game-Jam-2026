extends Node

@onready var label: Label3D = $Label3D
@onready var timer: Timer = $"../Timer"
@onready var main = $"../"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func time_left():
	var time_passed = main.time_for_documents - timer.time_left
	var time_left = timer.time_left
	var minutes = 9 + floor(time_passed / 60)
	var seconds = int(time_passed) % 60
	return [minutes, seconds]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%02d:%02d" % time_left()
