
class_name BaseMove


extends Control


@export var move_parent : Node3D = null
@export var base_move_duration : float = 0.7
@export var base_move_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var base_move_transition : Tween.TransitionType = Tween.TRANS_QUAD

@export var base_start_scale : Vector3 = Vector3(1, 1, 1)
@export var base_end_scale : Vector3 = Vector3(1, 1,1)


@export var receives_input : bool = false

var original_input = receives_input # Store the original input state to restore it after moves.

# Register your callbacks for when the move is finished here
signal move_finished

signal is_shown
signal is_hidden

func show_item():
	is_shown.emit()

func hide_item():
	is_hidden.emit()


func move(startPos : Vector3, endPos : Vector3, startRot : Vector3, endRot : Vector3, startScale : Vector3, endScale : Vector3, duration : float, ease : Tween.EaseType = base_move_ease, transition : Tween.TransitionType = base_move_transition):
	if move_parent == null:
		print("ERROR: Move Parent is not set.")

	var start_rot_rad = Vector3(deg_to_rad(startRot.x), deg_to_rad(startRot.y), deg_to_rad(startRot.z))
	var end_rot_rad = Vector3(deg_to_rad(endRot.x), deg_to_rad(endRot.y), deg_to_rad(endRot.z))

	original_input = receives_input
	receives_input = false # Disable input during the move to prevent interference. It will be re-enabled when the tween finishes.

	move_parent.position = startPos
	move_parent.scale = startScale
	move_parent.rotation = start_rot_rad

	var tween = create_tween()
	tween.set_trans(transition)
	tween.set_ease(ease)
	tween.tween_property(move_parent, "position", endPos, duration)
	tween.parallel().tween_property(move_parent, "rotation", end_rot_rad, duration) 
	tween.parallel().tween_property(move_parent, "scale", endScale, duration)

	tween.finished.connect(restore_input)
	tween.finished.connect(func(): move_finished.emit()) # Emit the move_finished signal when the tween is done.

func restore_input():
	receives_input = original_input
