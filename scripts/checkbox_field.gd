@tool
extends Field

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()

@export_flags("Left", "Middle", "Right")
var correct_answers: int = 0

# Icon variants (unchecked / checked)
@export var red_unchecked: Texture2D
@export var red_checked: Texture2D

@export var green_unchecked: Texture2D
@export var green_checked: Texture2D

@export var blue_unchecked: Texture2D
@export var blue_checked: Texture2D

# Fonts
@export var red_font: Font
@export var green_font: Font
@export var blue_font: Font

@export var red_font_size: int = 16
@export var green_font_size: int = 32
@export var blue_font_size: int = 16

@onready var checkbox_list: ItemList = %CheckboxList

var checked: Array[bool] = []

func _ready():
	if not checkbox_list:
		return

	checkbox_list.select_mode = ItemList.SELECT_MULTI
	checkbox_list.item_clicked.connect(_on_item_selected)

	checked.resize(checkbox_list.item_count)
	for i in range(checkbox_list.item_count):
		checked[i] = checkbox_list.is_selected(i)

	_request_update()

# --- TOOL REFRESH SYSTEM ---
func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_items")

# --- MAIN UPDATE ---
func _update_items():
	if not is_inside_tree() or not checkbox_list:
		return

	_apply_font()

	for i in range(checkbox_list.item_count):
		var icon := _get_checked_icon() if checked[i] else _get_unchecked_icon()
		checkbox_list.set_item_icon(i, icon)

# --- INPUT HANDLING ---
func _on_item_selected(index: int, _pos: Vector2, _mouse_button_index: int) -> void:
	checked[index] = !checked[index]
	checkbox_list.set_item_icon(
		index,
		_get_checked_icon() if checked[index] else _get_unchecked_icon()
	)

# --- ICON LOGIC ---
func _get_unchecked_icon() -> Texture2D:
	match color_type:
		ColorType.RED: return red_unchecked
		ColorType.GREEN: return green_unchecked
		ColorType.BLUE: return blue_unchecked
	return null

func _get_checked_icon() -> Texture2D:
	match color_type:
		ColorType.RED: return red_checked
		ColorType.GREEN: return green_checked
		ColorType.BLUE: return blue_checked
	return null

# --- FONT LOGIC ---
func _apply_font():
	# reset first so switching types doesn't stack overrides
	checkbox_list.remove_theme_font_override("font")
	checkbox_list.remove_theme_font_size_override("font_size")

	match color_type:
		ColorType.RED:
			if red_font:
				checkbox_list.add_theme_font_override("font", red_font)
				checkbox_list.add_theme_font_size_override("font_size", red_font_size)

		ColorType.GREEN:
			if green_font:
				checkbox_list.add_theme_font_override("font", green_font)
				checkbox_list.add_theme_font_size_override("font_size", green_font_size)

		ColorType.BLUE:
			if blue_font:
				checkbox_list.add_theme_font_override("font", blue_font)
				checkbox_list.add_theme_font_size_override("font_size", blue_font_size)

# --- CHECK RESULT ---
func evaluate() -> bool:
	var result_mask := 0

	for i in range(min(3, checked.size())):
		if checked[i]:
			result_mask |= (1 << i)

	print("The field is:", result_mask == correct_answers)
	return result_mask == correct_answers
