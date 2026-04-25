extends Camera3D

@export var tween_duration: float = 0.6
@export var transition_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition_trans: Tween.TransitionType = Tween.TRANS_SINE

@export var edge_margin: int = 150
@export var trigger_margin: int = 50
@export var max_tilt: float = 5.0

enum CameraState { FORWARD, DOWN, LEFT, RIGHT }

var current_state: CameraState = CameraState.FORWARD
var base_rotation: Vector3
var _tween: Tween

var _zone_active := {
	"top": false,
	"bottom": false,
	"left": false,
	"right": false
}

func _ready() -> void:
	base_rotation = rotation

func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var screen_size := get_viewport().get_visible_rect().size

	_apply_tilt(mouse_pos, screen_size)
	_handle_triggers(mouse_pos, screen_size)

func _apply_tilt(mouse_pos: Vector2, screen_size: Vector2) -> void:
	var tilt := Vector2.ZERO
	var max_rad := deg_to_rad(max_tilt)

	var allow := {
		"top": current_state == CameraState.DOWN,
		"bottom": current_state == CameraState.FORWARD,
		"left": current_state == CameraState.FORWARD,
		"right": current_state == CameraState.FORWARD
	}

	if allow.top and mouse_pos.y < edge_margin:
		tilt.x = max_rad * (1.0 - mouse_pos.y / edge_margin)
	elif allow.bottom and mouse_pos.y > screen_size.y - edge_margin:
		tilt.x = -max_rad * (1.0 - (screen_size.y - mouse_pos.y) / edge_margin)
	elif allow.left and mouse_pos.x < edge_margin:
		tilt.y = max_rad * (1.0 - mouse_pos.x / edge_margin)
	elif allow.right and mouse_pos.x > screen_size.x - edge_margin:
		tilt.y = -max_rad * (1.0 - (screen_size.x - mouse_pos.x) / edge_margin)

	rotation.x = base_rotation.x + tilt.x
	rotation.y = base_rotation.y + tilt.y

func _handle_triggers(mouse_pos: Vector2, screen_size: Vector2) -> void:
	_handle_zone(
		"top",
		mouse_pos.y < trigger_margin,
		func():
			if _is_tweening(): return
			if current_state == CameraState.DOWN:
				look_forward()
	)

	_handle_zone(
		"bottom",
		mouse_pos.y > screen_size.y - trigger_margin,
		func():
			if _is_tweening(): return
			if current_state == CameraState.FORWARD:
				look_down()
	)

	_handle_zone(
		"left",
		mouse_pos.x < trigger_margin,
		func():
			if _is_tweening(): return
			if current_state == CameraState.FORWARD:
				look_left()
			elif current_state == CameraState.RIGHT:
				look_forward()
	)

	_handle_zone(
		"right",
		mouse_pos.x > screen_size.x - trigger_margin,
		func():
			if _is_tweening(): return
			if current_state == CameraState.FORWARD:
				look_right()
			elif current_state == CameraState.LEFT:
				look_forward()
	)

func _handle_zone(key: String, condition: bool, action: Callable) -> void:
	if condition:
		if not _zone_active[key]:
			_zone_active[key] = true
			action.call()
	else:
		_zone_active[key] = false

func _is_tweening() -> bool:
	return _tween != null and _tween.is_running()

func _kill_tween() -> void:
	if _is_tweening():
		_tween.kill()

func _transition_to(target_rotation: Vector3, target_fov: float, state: CameraState) -> void:
	if current_state == state or _is_tweening():
		return

	current_state = state

	_tween = create_tween()
	_tween.set_ease(transition_ease)
	_tween.set_trans(transition_trans)

	_tween.tween_property(self, "rotation", target_rotation, tween_duration)
	_tween.parallel().tween_property(self, "fov", target_fov, tween_duration)
	_tween.finished.connect(func(): base_rotation = target_rotation)

func look_down() -> void:
	_transition_to(Vector3(deg_to_rad(-50), rotation.y, rotation.z), 55.0, CameraState.DOWN)

func look_forward() -> void:
	_transition_to(Vector3(0, 0, rotation.z), 35.0, CameraState.FORWARD)

func look_left() -> void:
	_transition_to(Vector3(0, deg_to_rad(45), rotation.z), 35.0, CameraState.LEFT)

func look_right() -> void:
	_transition_to(Vector3(0, deg_to_rad(-45), rotation.z), 35.0, CameraState.RIGHT)
