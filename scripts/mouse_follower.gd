extends TextureRect
class_name Hand

@export var strength: float = 25.0
@export var damping: float = 1.5 # low damping to keep oscillation
# enforce minimum velocity magnitude
@export var min_speed: float = 20.0

var velocity: Vector2 = Vector2.ZERO
var following_mouse: bool = true

func _get_offset_from_mouse() -> Vector2:
	var mouse_pos: Vector2 =  get_global_mouse_position()
	return (mouse_pos - (global_position + (size * 0.5)))


func hide_hand() -> void:
	following_mouse = false
	
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var off_screen_pos: Vector2 = Vector2(global_position.x, screen_size.y + size.y * 0.6)
	
	create_tween().tween_property(self, "global_position", off_screen_pos, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN).finished.connect(func(): hide())


func show_hand() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var target: Vector2 = Vector2(mouse_pos.x, screen_size.y + 400)
	
	global_position = target
	following_mouse = true
	show()

func _process(delta: float) -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	
	var pos: Vector2 = global_position
	var target: Vector2 = pos
	
	if following_mouse:
		var mouse_pos: Vector2 = get_global_mouse_position()
		target = mouse_pos - (size * 0.5)
		
		target.x = clamp(target.x, -(size * 0.5).x, screen_size.x - (size * 0.5).x)
		target.y = clamp(target.y, -(size * 0.5).y, screen_size.y - (size * 0.5).y)
	
	# spring force (causes overshoot)
	var force: Vector2 = (target - pos) * strength
	velocity += force * delta
	
	# light damping so it never fully settles
	velocity *= 1.0 / (1.0 + damping * delta)
	if velocity.length() < min_speed:
		if velocity.length() == 0.0:
			velocity = (target - pos).normalized() * min_speed
		else:
			velocity = velocity.normalized() * min_speed
		
	pos += velocity * delta
	
	# keep inside bounds but DO NOT kill velocity (allows bounce/overshoot feel)
	if pos.x < -(size * 0.5).x:
		pos.x = -(size * 0.5).x
	elif pos.x > screen_size.x - (size * 0.5).x:
		pos.x = screen_size.x - (size * 0.5).x

	if pos.y < -(size * 0.5).y:
		pos.y = -(size * 0.5).y
	elif pos.y > screen_size.y - (size * 0.5).y:
		pos.y = screen_size.y - (size * 0.5).y

	global_position = pos
