class_name Helpbook

extends BaseMove

@export var left_pages : Array[Control]
@export var right_pages : Array[Control]

@export var page_turn_duration : float = 0.2

@export var left_arrow : RichTextLabel
@export var right_arrow : RichTextLabel

@export var table_pos : Vector3

var current_page : int = 0

var total_pages : int = 5

var can_browse : bool = false

func show_page(index : int):
	receives_input = false
	var fadeout_tween = get_tree().create_tween()
	fadeout_tween.tween_property(left_pages[current_page], "modulate:a", 0, page_turn_duration)
	fadeout_tween.tween_property(right_pages[current_page], "modulate:a", 0, page_turn_duration)
	await fadeout_tween.finished
	current_page = index

	var fadein_tween = get_tree().create_tween()
	fadein_tween.tween_property(left_pages[current_page], "modulate:a", 1, page_turn_duration)
	fadein_tween.tween_property(right_pages[current_page], "modulate:a", 1, page_turn_duration)
	await fadein_tween.finished
	receives_input = true

func next_page():
	if receives_input:
		if current_page < total_pages - 1:
			show_page(current_page + 1)

		if current_page == total_pages - 1:
			right_arrow.theme_override_colors.font_color = Color(0.5, 0.5, 0.5)

func previous_page():
	if receives_input:
		if current_page > 0:
			show_page(current_page - 1)

		if current_page == 0:
			left_arrow.theme_override_colors.font_color = Color(0.5, 0.5, 0.5)
func change_parent(new_parent : Node3D):
	move_parent.reparent(new_parent)

func enable_browsing():
	move_finished.disconnect(enable_browsing)
	can_browse = true

func select():
	change_parent(GameManager.player_face)
	move_finished.connect(enable_browsing)
	move(move_parent.position, selection_pos, move_parent.rotation, selection_rot, move_parent.scale, base_end_scale, base_move_duration, base_move_ease, base_move_transition)

func put_on_table():
	can_browse = false
	change_parent(GameManager.table_object)
	move(move_parent.position, table_pos, move_parent.rotation, Vector3(-90, 0,0), move_parent.scale, base_start_scale, base_move_duration, base_move_ease, base_move_transition)

func on_helpbook_input():
	if receives_input:
		if can_browse:
			put_on_table()
		else:
			select()