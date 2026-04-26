extends TextureRect

@export var strength: float = 25.0
@export var damping: float = 8.0

var velocity: Vector2 = Vector2.ZERO

func _get_offset_from_mouse() -> Vector2:
	var mouse_pos: Vector2 = get_global_mouse_position()
	return (mouse_pos - (global_position + (size * 0.5)))

func _process(delta: float) -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	
	# mouse position in global space
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	# we want the pivot to sit on the mouse
	var target: Vector2 = mouse_pos - (size * 0.5)
	
	# clamp so pivot stays inside screen bounds
	target.x = clamp(target.x, -(size * 0.5).x, screen_size.x - (size * 0.5).x)
	target.y = clamp(target.y, -(size * 0.5).y, screen_size.y - (size * 0.5).y)
	
	var pos: Vector2 = global_position
	
	var force: Vector2 = (target - pos) * strength
	velocity += force * delta
	
	velocity *= exp(-damping * delta)
	
	pos += velocity * delta
	
	# enforce bounds (and kill velocity on impact)
	if pos.x < -(size * 0.5).x:
		pos.x = -(size * 0.5).x
		velocity.x = 0.0
	elif pos.x > screen_size.x - (size * 0.5).x:
		pos.x = screen_size.x - (size * 0.5).x
		velocity.x = 0.0

	if pos.y < -(size * 0.5).y:
		pos.y = -(size * 0.5).y
		velocity.y = 0.0
	elif pos.y > screen_size.y - (size * 0.5).y:
		pos.y = screen_size.y - (size * 0.5).y
		velocity.y = 0.0

	global_position = pos
