@tool
extends Field

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()

@onready var rich_text_label: RichTextLabel = %Label
@onready var photo: TextureRect = %Photo
@onready var photo_frame: TextureRect = %PhotoFrame

@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var red_font_size: int
@export var green_font_size: int 
@export var blue_font_size: int


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			debug_place_photo_at_mouse()


func _get_screen_pos() -> Vector2:
	var viewport: Viewport = get_viewport()
	var host: Node = viewport.get_parent()

	if host == null:
		push_error("GUI_3D host not found (viewport has no parent).")
		return Vector2.ZERO

	if not (host is GUI_3D):
		push_error("Parent is not GUI_3D. Got: %s" % [host])
		return Vector2.ZERO

	var gui_3d: GUI_3D = host
	var quad: MeshInstance3D = gui_3d.node_quad

	if quad == null:
		push_error("GUI_3D.node_quad is null.")
		return Vector2.ZERO

	if quad.mesh == null:
		push_error("Quad mesh is null.")
		return Vector2.ZERO

	var rect: Rect2 = photo.get_global_rect()
	var sub_size: Vector2 = viewport.size

	if sub_size == Vector2.ZERO:
		push_error("Viewport size is zero.")
		return Vector2.ZERO

	var uv: Vector2 = rect.position / sub_size

	var quad_size: Vector2 = quad.mesh.size

	var local_quad_pos: Vector3 = Vector3(
		(uv.x - 0.5) * quad_size.x,
		(0.5 - uv.y) * quad_size.y,
		0.0
	)

	var world_pos: Vector3 = quad.global_transform * local_quad_pos

	var camera: Camera3D = GameManager.camera_node
	if camera == null:
		push_error("No Camera3D found in viewport.")
		return Vector2.ZERO

	return camera.unproject_position(world_pos)

func debug_place_photo_at_mouse():
	if not is_inside_tree():
		return

	var hud_photo_size := HUD.picture.size
	var mouse_pos := HUD.picture.global_position - (hud_photo_size * 0.5)

	print(_get_screen_pos())

	# center the photo on the mouse position
	var photo_size := photo.size
	photo.global_position = mouse_pos - (photo_size * 0.5)

	var frame_center := photo_frame.global_position + (photo_frame.size * 0.5)
	var distance := mouse_pos.distance_to(frame_center)

	print("Distance from photo_frame: ", distance)

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")


func _update_ui():
	if not is_inside_tree():
		return
		
	%Label.remove_theme_font_override("normal_font")
	%Label.remove_theme_font_size_override("normal_font_size")

	match color_type:
		ColorType.RED:
			if red_font:
				%Label.add_theme_font_override("normal_font", red_font)
				%Label.add_theme_font_size_override("normal_font_size", red_font_size)

		ColorType.GREEN:
			if green_font:
				%Label.add_theme_font_override("normal_font", green_font)
				%Label.add_theme_font_size_override("normal_font_size", green_font_size)

		ColorType.BLUE:
			if blue_font:
				%Label.add_theme_font_override("normal_font", blue_font)
				%Label.add_theme_font_size_override("normal_font_size", blue_font_size)


func evaluate() -> bool:
	return true
