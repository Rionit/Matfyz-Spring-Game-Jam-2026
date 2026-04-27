@tool
extends RichTextLabel

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()
		
@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var font_size: int:
	set(value):
		font_size = value
		_request_update()

func _ready():
	_request_update()

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")

func _update_ui():
	if not is_inside_tree():
		return
		
	remove_theme_font_override("normal_font")
	remove_theme_font_size_override("normal_font_size")
	
	match color_type:
		ColorType.RED:
			add_theme_color_override("default_color", Color(0.359, 0.0, 0.0, 1.0))
			if red_font:
				add_theme_font_override("normal_font", red_font)
				add_theme_font_size_override("normal_font_size", font_size)

		ColorType.GREEN:
			add_theme_color_override("default_color", Color(0.0, 0.33, 0.0, 1.0)) 
			if green_font:
				add_theme_font_override("normal_font", green_font)
				add_theme_font_size_override("normal_font_size", font_size)

		ColorType.BLUE:
			add_theme_color_override("default_color", Color(0.116, 0.148, 0.29, 1.0)) 
			if blue_font:
				add_theme_font_override("normal_font", blue_font)
				add_theme_font_size_override("normal_font_size", font_size)
