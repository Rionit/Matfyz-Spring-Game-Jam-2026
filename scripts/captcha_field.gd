@tool
extends Field

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()
		
@export_flags("Red", "Green", "Blue", "Human")
var correct_answer_types: int = 0

@export_tool_button("Randomize captcha items", "Callable") var randomize_action = _randomize

@onready var rich_text_label: RichTextLabel = %Label
@onready var captcha: ItemList = %Captcha
@onready var submit_button: Button = %SubmitButton

@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var red_font_size: int
@export var green_font_size: int 
@export var blue_font_size: int 

@export var captcha_icons: Array[Texture2D] = []

func _ready():
	_randomize()
	call_deferred("_update_ui")

func _randomize():
	for i in range(captcha.item_count):
		captcha.set_item_icon(i, captcha_icons.pick_random())

		
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

func check_captcha() -> bool:
	for i in range(captcha.item_count):
		var icon: Texture2D = captcha.get_item_icon(i)
		var icon_idx := captcha_icons.find(icon)
		
		var is_correct_type := (correct_answer_types & (1 << icon_idx)) != 0
		var is_selected := captcha.is_selected(i)
		
		# If a correct type is NOT selected → fail
		if is_correct_type and not is_selected:
			return false
		
		# If a wrong type IS selected → fail
		if not is_correct_type and is_selected:
			return false
	
	return true

func _fail_feedback_and_reroll() -> void:
	
	#for i in range(captcha.item_count):
		#if captcha.is_selected(i):
			#captcha.select(i)
			
	captcha.deselect_all()
	
	# Tween for quick visual feedback (shake + fade)
	var tween := create_tween()
	
	# Shake effect
	var original_pos := captcha.position
	var original_scale := captcha.scale
	
	tween.tween_property(captcha, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(captcha, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(captcha, "position:x", original_pos.x, 0.05)
	
	# red flash + slight "error shrink pop"
	tween.parallel().tween_property(captcha, "modulate", Color(1.0, 0.5, 0.5), 0.15)
	tween.parallel().tween_property(captcha, "scale", original_scale * 0.95, 0.15)
	tween.tween_property(captcha, "scale", original_scale, 0.15)
	
	# Fade out
	tween.parallel().tween_property(captcha, "modulate:a", 0.3, 0.2)
	tween.tween_interval(2.0)
	
	# Fade back in
	tween.tween_property(captcha, "modulate:a", 1.0, 0.2)
	tween.tween_property(captcha, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func():
		_randomize()
	)

func _success_feedback() -> void:
	var tween := create_tween()

	var original_scale := captcha.scale

	for i in range(captcha.item_count):
		captcha.set_item_disabled(i, true)
		
	submit_button.disabled = true

	# quick "pop"
	tween.tween_property(captcha, "scale", original_scale * 1.05, 0.08)
	tween.tween_property(captcha, "scale", original_scale, 0.08)

	# green tint flash
	captcha.modulate = Color.WHITE
	tween.parallel().tween_property(captcha, "modulate", Color(0.6, 1.0, 0.6), 0.15)
	tween.tween_property(captcha, "modulate", Color.WHITE, 0.25)

func test():
	print(check_captcha())
	if not check_captcha():
		_fail_feedback_and_reroll()
	else:
		_success_feedback()

func evaluate() -> bool:
	return check_captcha() 
