extends Camera3D

@export var tween_duration: float = 0.6
@export var transition_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition_trans: Tween.TransitionType = Tween.TRANS_SINE

@export var edge_margin: int = 150
@export var trigger_margin: int = 50
@export var max_tilt: float = 5.0

enum CameraState {
	FORWARD,
	DOWN,
	LEFT,
	RIGHT
}

var current_state: CameraState = CameraState.FORWARD
var base_rotation: Vector3
var _tween: Tween

var _top_zone_active := false
var _bottom_zone_active := false
var _left_zone_active := false
var _right_zone_active := false

func _ready() -> void:
	base_rotation = rotation

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	var tilt_x := 0.0
	var tilt_y := 0.0

	var allow_top_tilt := current_state != CameraState.FORWARD
	var allow_bottom_tilt := current_state != CameraState.DOWN
	var allow_left_tilt := current_state == CameraState.FORWARD
	var allow_right_tilt := current_state == CameraState.FORWARD

	# --- Vertical tilt ---
	if allow_top_tilt and mouse_pos.y < edge_margin:
		var t = 1.0 - (mouse_pos.y / edge_margin)
		tilt_x = deg_to_rad(max_tilt) * t
	elif allow_bottom_tilt and mouse_pos.y > screen_size.y - edge_margin:
		var t = 1.0 - ((screen_size.y - mouse_pos.y) / edge_margin)
		tilt_x = -deg_to_rad(max_tilt) * t

	# --- Horizontal tilt ---
	if allow_left_tilt and mouse_pos.x < edge_margin:
		var t = 1.0 - (mouse_pos.x / edge_margin)
		tilt_y = deg_to_rad(max_tilt) * t
	elif allow_right_tilt and mouse_pos.x > screen_size.x - edge_margin:
		var t = 1.0 - ((screen_size.x - mouse_pos.x) / edge_margin)
		tilt_y = -deg_to_rad(max_tilt) * t

	rotation.x = base_rotation.x + tilt_x
	rotation.y = base_rotation.y + tilt_y

	# --- TOP trigger ---
	if mouse_pos.y < trigger_margin:
		if not _top_zone_active:
			_top_zone_active = true
			if current_state != CameraState.FORWARD:
				look_forward()
	else:
		_top_zone_active = false

	# --- BOTTOM trigger ---
	if mouse_pos.y > screen_size.y - trigger_margin:
		if not _bottom_zone_active:
			_bottom_zone_active = true
			if current_state != CameraState.DOWN:
				look_down()
	else:
		_bottom_zone_active = false

	# --- LEFT trigger ---
	if mouse_pos.x < trigger_margin:
		if not _left_zone_active:
			_left_zone_active = true
			if current_state == CameraState.FORWARD:
				look_left()
	else:
		_left_zone_active = false

	# --- RIGHT trigger ---
	if mouse_pos.x > screen_size.x - trigger_margin:
		if not _right_zone_active:
			_right_zone_active = true
			if current_state == CameraState.FORWARD:
				look_right()
	else:
		_right_zone_active = false

	# --- Return to FORWARD when leaving edge ---
	if current_state == CameraState.LEFT and mouse_pos.x > edge_margin:
		look_forward()

	if current_state == CameraState.RIGHT and mouse_pos.x < screen_size.x - edge_margin:
		look_forward()

func _kill_tween():
	if _tween and _tween.is_running():
		_tween.kill()

func look_right():
	if current_state == CameraState.RIGHT:
		return

	current_state = CameraState.RIGHT

	_kill_tween()
	_tween = create_tween()
	_tween.set_ease(transition_ease)
	_tween.set_trans(transition_trans)

	var target_rotation = Vector3(rotation.x, deg_to_rad(-45), rotation.z)
	var target_fov = 35.0

	_tween.tween_property(self, "rotation", target_rotation, tween_duration)
	_tween.parallel().tween_property(self, "fov", target_fov, tween_duration)
	_tween.finished.connect(func(): base_rotation = target_rotation)

func look_left():
	if current_state == CameraState.LEFT:
		return

	current_state = CameraState.LEFT

	_kill_tween()
	_tween = create_tween()
	_tween.set_ease(transition_ease)
	_tween.set_trans(transition_trans)

	var target_rotation = Vector3(rotation.x, deg_to_rad(45), rotation.z)
	var target_fov = 35.0

	_tween.tween_property(self, "rotation", target_rotation, tween_duration)
	_tween.parallel().tween_property(self, "fov", target_fov, tween_duration)
	_tween.finished.connect(func(): base_rotation = target_rotation)

func look_down():
	if current_state == CameraState.DOWN:
		return

	current_state = CameraState.DOWN

	_kill_tween()
	_tween = create_tween()
	_tween.set_ease(transition_ease)
	_tween.set_trans(transition_trans)

	var target_rotation = Vector3(deg_to_rad(-50), rotation.y, rotation.z)
	var target_fov = 55.0

	_tween.tween_property(self, "rotation", target_rotation, tween_duration)
	_tween.parallel().tween_property(self, "fov", target_fov, tween_duration)
	_tween.finished.connect(func(): base_rotation = target_rotation)

func look_forward():
	if current_state == CameraState.FORWARD:
		return

	current_state = CameraState.FORWARD

	_kill_tween()
	_tween = create_tween()
	_tween.set_ease(transition_ease)
	_tween.set_trans(transition_trans)

	var target_rotation = Vector3(0, 0, rotation.z)
	var target_fov = 35.0

	_tween.tween_property(self, "rotation", target_rotation, tween_duration)
	_tween.parallel().tween_property(self, "fov", target_fov, tween_duration)
	_tween.finished.connect(func(): base_rotation = target_rotation)
