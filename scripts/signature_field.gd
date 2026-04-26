@tool
extends Field

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()

@onready var field: TextureRect = %Field
@onready var signature: TextureRect = %Signature

@onready var rich_text_label: RichTextLabel = %Text

@export var red_field: Texture2D
@export var green_field: Texture2D
@export var blue_field: Texture2D

@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var red_font_size: int
@export var green_font_size: int 
@export var blue_font_size: int 

@export_range(2000, 6000) var max_progress: float = 5000.0

var mouse_down := false
var is_hovering := false
var last_mouse_pos := Vector2.ZERO
var progress := 0.0

var field_result: bool = false
var finished: bool = false

func _ready():
	call_deferred("_update_ui")
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

func _process(delta: float) -> void:
	if not finished:
		var reveal_value = progress / max_progress
		(signature.material as ShaderMaterial).set_shader_parameter("reveal", reveal_value)

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")

func _update_ui():
	if not is_inside_tree():
		return
		
	%Text.remove_theme_font_override("normal_font")
	%Text.remove_theme_font_size_override("normal_font_size")

	match color_type:
		ColorType.RED:
			field.texture = red_field
			if red_font:
				%Text.add_theme_font_override("normal_font", red_font)
				%Text.add_theme_font_size_override("normal_font_size", red_font_size)

		ColorType.GREEN:
			field.texture = green_field
			if green_font:
				%Text.add_theme_font_override("normal_font", green_font)
				%Text.add_theme_font_size_override("normal_font_size", green_font_size)

		ColorType.BLUE:
			field.texture = blue_field
			if blue_font:
				%Text.add_theme_font_override("normal_font", blue_font)
				%Text.add_theme_font_size_override("normal_font_size", blue_font_size)

func _on_mouse_enter():
	if finished:
		return
	is_hovering = true
	last_mouse_pos = get_global_mouse_position()

func _on_mouse_exit():
	if finished:
		return

	is_hovering = false

	# Only fail if the user was actively holding the mouse
	if mouse_down:
		field_result = false
		finished = true
		print("Result:", field_result)

	mouse_down = false

func _gui_input(event):
	if finished:
		return

	# Track mouse button state
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = event.pressed

	# Only count progress if hovering AND mouse is held down
	if is_hovering and mouse_down and event is InputEventMouseMotion:
		var current_pos = event.global_position
		var delta = current_pos - last_mouse_pos
		last_mouse_pos = current_pos

		progress += delta.length()
		print("Progress:", progress)

		if progress >= max_progress:
			field_result = true
			finished = true
			print("Result:", field_result)

func evaluate() -> bool:
	return field_result
