class_name Helpbook

extends BaseMove

@export var left_pages : Array[Control]
@export var right_pages : Array[Control]

@export var page_turn_duration : float = 0.05

@export var left_arrow : TextureRect
@export var right_arrow : TextureRect

@export var table_pos : Vector3

@export var highlight : Control

@export var default_arrow_color : Color = Color("da8f73")

var current_page : int = 0

var total_pages : int = 5

var can_browse : bool = false

func show_page(index : int):
	receives_input = false
	var fadeout_tween = get_tree().create_tween()
	fadeout_tween.tween_property(left_pages[current_page], "modulate:a", 0, page_turn_duration)
	fadeout_tween.tween_property(right_pages[current_page], "modulate:a", 0, page_turn_duration)
	await fadeout_tween.finished
	left_pages[current_page].visible = false
	right_pages[current_page].visible = false
	
	current_page = index
	
	left_pages[current_page].visible = true
	right_pages[current_page].visible = true

	var fadein_tween = get_tree().create_tween()
	fadein_tween.tween_property(left_pages[current_page], "modulate:a", 1, page_turn_duration)
	fadein_tween.tween_property(right_pages[current_page], "modulate:a", 1, page_turn_duration)
	await fadein_tween.finished
	receives_input = true

func next_page():
	if receives_input and can_browse:
		left_arrow.modulate = default_arrow_color

		if current_page >= total_pages - 2:
			right_arrow.modulate = Color(0.5, 0.5, 0.5)
		else:
			right_arrow.modulate = default_arrow_color

		if current_page < total_pages - 1:
			show_page(current_page + 1)

func previous_page():
	if can_browse and receives_input:
		right_arrow.modulate = default_arrow_color
		if current_page <= 1:
			left_arrow.modulate = Color(0.5, 0.5, 0.5)
		else:
			left_arrow.modulate = default_arrow_color

		if current_page > 0:
			show_page(current_page - 1)

func change_parent(new_parent : Node3D):
	move_parent.reparent(new_parent)

func enable_browsing():
	move_finished.disconnect(enable_browsing)
	can_browse = true

func select():
	highlight.visible = false
	change_parent(GameManager.player_face)
	move_finished.connect(enable_browsing)
	move(move_parent.position, selection_pos, move_parent.rotation_degrees, selection_rot, move_parent.scale, base_end_scale, base_move_duration, base_move_ease, base_move_transition)

func put_on_table():
	can_browse = false
	change_parent(GameManager.table_object)
	move(move_parent.position, table_pos, move_parent.rotation_degrees, Vector3(-90, 0,0), move_parent.scale, base_start_scale, base_move_duration, base_move_ease, base_move_transition)

func on_helpbook_input():
	if receives_input:
		if !can_browse:
			select()
		else:
			put_on_table()

func on_mouse_entered():
	if receives_input and !can_browse:
		highlight.visible = true
func on_mouse_exited():
	highlight.visible = false

func on_input_event(event : InputEvent):
	if event is InputEventMouseButton and !event.pressed and !can_browse:
		on_helpbook_input()

func _ready() -> void:
	right_arrow.modulate = default_arrow_color
	left_arrow.modulate = Color(0.5, 0.5, 0.5)
	receives_input = true
