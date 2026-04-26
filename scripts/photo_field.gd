@tool
extends Field

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()

@export var valid_distance_threshold: float

@onready var rich_text_label: RichTextLabel = %Label
@onready var photo: TextureRect = %Photo
@onready var photo_frame: TextureRect = %PhotoFrame

@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var red_font_size: int
@export var green_font_size: int 
@export var blue_font_size: int

var photo_distance: float

func _ready() -> void:
	_request_update()
	photo.hide()

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

	var rect: Rect2 = photo_frame.get_global_rect()
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

func screen_to_subviewport(screen_pos: Vector2) -> Vector2:
	var viewport: Viewport = get_viewport()
	var host: Node = viewport.get_parent()

	if host == null or not (host is GUI_3D):
		push_error("Invalid GUI_3D host.")
		return Vector2.ZERO

	var gui_3d: GUI_3D = host
	var quad: MeshInstance3D = gui_3d.node_quad

	if quad == null or quad.mesh == null:
		push_error("Quad or mesh is null.")
		return Vector2.ZERO

	var camera: Camera3D = GameManager.camera_node
	if camera == null:
		push_error("No Camera3D found.")
		return Vector2.ZERO

	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var dir: Vector3 = camera.project_ray_normal(screen_pos)

	var plane: Plane = Plane(quad.global_transform.basis.z, quad.global_transform.origin)
	var world_pos: Variant = plane.intersects_ray(from, dir)

	if world_pos == null:
		return Vector2.ZERO

	var local_pos: Vector3 = quad.global_transform.affine_inverse() * world_pos
	var quad_size: Vector2 = quad.mesh.size

	var uv: Vector2 = Vector2(
		local_pos.x / quad_size.x + 0.5,
		- local_pos.y / quad_size.y + 0.5
	)

	var vp_size: Vector2 = Vector2(viewport.size)
	return uv * vp_size

func place_photo_at_mouse():
	if not is_inside_tree():
		return

	# center the photo on the mouse position
	var photo_size := photo.size
	photo.global_position = screen_to_subviewport(HUD.picture.global_position + (HUD.picture.size * 0.5)) - (photo_size * 0.5)

	var frame_center := photo_frame.global_position + (photo_frame.size * 0.5)
	var photo_pos = photo.global_position + (photo_size * 0.5)
	var distance := photo_pos.distance_to(frame_center)
	
	HUD.hide_picture()
	photo.show()
	
	photo_distance = distance
	
	if not evaluate():
		photo.rotation += sign(randf() - 0.5) * randf_range(0.1, 0.3)
	
	document.enable_fields()
	
	print("Distance from photo_frame: ", distance, " and result is: ", evaluate(), " and: ", photo_distance < valid_distance_threshold)

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
	return photo_distance <= valid_distance_threshold and photo.visible

func _on_button_pressed() -> void:
	if receives_input and HUD.is_hand_hidden:
		HUD.show_picture()
		document.disable_fields_except(self)
	elif receives_input and not HUD.is_hand_hidden:
		place_photo_at_mouse()
