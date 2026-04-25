class_name TestMove

extends BaseMove
## After mouse enters the node, animates the object from start to end and back. Waits for the animation to finish before allowing another click.

@export var test_move_duration : float = 0.7
@export var test_move_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var test_move_transition : Tween.TransitionType = Tween.TransitionType.TRANS_QUAD

@export var test_move_start_position : Vector3 = Vector3(0, 0, 0)
@export var test_move_end_position : Vector3 = Vector3(1, 0, 0)

@export var test_move_start_rotation : Vector3 = Vector3(0, 0, 0)
@export var test_move_end_rotation : Vector3 = Vector3.ZERO

var move_back = true

func test_move():
	print("Performing test move!")

	var startPos
	var endPos
	var startRot
	var endRot

	if !move_back:
		startPos = test_move_start_position
		endPos = test_move_end_position
		startRot = test_move_start_rotation
		endRot = test_move_end_rotation
	else:
		startPos = test_move_end_position
		endPos = test_move_start_position
		startRot = test_move_end_rotation
		endRot = test_move_start_rotation

	move_finished.connect(test_callback)

	move(startPos, endPos, startRot, endRot, test_move_duration, test_move_ease, test_move_transition)

func test_callback():
	move_finished.disconnect(test_callback) # Disconnect the callback to prevent it from being called again on future moves.
	print("Move finished callback called!")

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	test_move()
#	pass # Replace with function body.

func on_click():
	print("Node clicked!")
	if receives_input:
		move_back = !move_back
		test_move()

func _on_area_3d_mouse_entered() -> void:
	pass # Replace with function body.
