
class_name DocumentController

extends BaseMove

@export var fields : Array[Field]

enum DocState {
	HIDDEN,
	LISTED,
	ON_TABLE,
	SELECTED,
	SELECTED_RULEBOOK,
	SELECTED_TOP
}

var current_state = DocState.HIDDEN

# Default position on the table where the document should be put
@export var default_table_pos : Vector3

@export var top_look_pos : Vector3
@export var top_look_rot : Vector3
@export var highlight_overlay : Control

var current_table_pos : Vector3

# Position where to hide the document in the folder (Where to animate) 
var folder_hidden_pos : Vector3

# World position where the document should be when it's listed on the table (Where to animate)
var folder_listed_pos : Vector3

var submitted : bool = false

var can_highlight : bool = false
var can_click : bool = false

var can_drag_drop : bool = false # Whether the document can be dragged & dropped
var counting_drag_drop : bool = false # Whether the cooldown for drag & drop is currently counted
var is_drag_dropping : bool = false # Whether the document is currently being dragged & dropped

@export var drag_drop_table_height_offset : float = 0.01


@export var drag_drop_time : float = 0.8
var current_drag_drop_time : float = 0.0


@export var listed_scale : Vector3 = Vector3(0.3,0.3,0.3)

# Hidden -> Listed
# Moves from folder base position to listed position
# CONTROLLED BY FOLDER
# CAN be higlighted
# CAN be clicked (selects document on click)
# CAN't click fields

# Listed -> Hidden
# Moves from listed position to folder base position
# CONTROLLED BY FOLDER
# CAN'T be higlighted
# CAN'T be clicked
# CAN'T click fields

# Listed -> Selected
# Moves from listed position to selected
# CAN'T be higlighted
# CAN'T be clicked
# CAN click fields

# Selected -> Selected Rulebook
# Moves the document to the side
# CAN'T be higlighted
# CAN'T be clicked
# CAN click fields

# Selected/Selected Rulebook -> Selected Top
# Saves the last state
# Tilts the document to the top
# CAN'T be higlighted
# CAN'T be clicked
# CAN'T click fields

# Selected Top -> Selected/Selected Rulebook
# Moves the document back to the last position, switches to the last state
# CAN'T be higlighted
# CAN'T be clicked (click on document doesn't have an effect)
# CAN click fields

# Selected/Selected Rulebook -> On Table
# Moves the document to the last table position (or to the middle of the table)
# CAN be highlighted
# CAN be clicked (selects document on click)
# CAN'T click fields

func evaluate() -> int:
	var total = 0
	for field in fields:
		total += field.evaluate()
	return total

### ENABLE/DISABLE TOGGLES

func enable_fields():
	move_finished.disconnect(enable_fields)
	for field in fields:
		field.receives_input = true
func disable_fields():
	for field in fields:
		field.receives_input = false

func enable_click():
	move_finished.disconnect(enable_click)
	can_click = true

func disable_click():
	can_click = false

func enable_highlight():
	move_finished.disconnect(enable_highlight)
	can_highlight = true

func disable_highlight():
	highlight_overlay.visible = false
	can_highlight = false

func enable_drag_drop():
	can_drag_drop = true

func disable_drag_drop():
	can_drag_drop = false

### ACTIONS (SELECT, PUT ON TABLE, STASH, MOVE TO TOP, MOVE FROM TOP)

func select(selectionPos : Vector3, selectionRot : Vector3):
	disable_click()
	disable_highlight()
	move_finished.connect(enable_fields)
	# TODO: Make helpbook offset conditional
	move(move_parent.position, selectionPos + GameManager.helpbook_offset, move_parent.rotation_degrees, selectionRot, move_parent.scale, Vector3.ONE, base_move_duration)

func put_on_table():
	disable_fields()

	move_finished.connect(enable_drag_drop)
	move_finished.connect(enable_highlight)
	move_finished.connect(enable_click)

func stash(folderPos : Vector3, folderRot : Vector3):	
	disable_click()
	disable_highlight()
	disable_drag_drop()
	move(move_parent.position, folderPos, move_parent.rotation_degrees, folderRot, move_parent.scale, Vector3.ZERO, base_move_duration)

func move_to_top():
	disable_fields()

	# TODO: Make helpbook offset conditional
	move(move_parent.position, top_look_pos + GameManager.helpbook_offset, move_parent.rotation_degrees, top_look_rot, move_parent.scale, Vector3.ONE, base_move_duration)

func move_from_top(selectionPos : Vector3, selectionRot : Vector3):
	#TODO: Make helpbook offset conditional

	move_finished.connect(enable_fields)
	move(move_parent.position, selectionPos + GameManager.helpbook_offset, move_parent.rotation_degrees, selectionRot, move_parent.scale, Vector3.ONE, base_move_duration)

func list(folderPos : Vector3, listPos : Vector3, listScale : Vector3):
	move_finished.connect(enable_highlight)
	move_finished.connect(enable_click)

	move(folderPos, listPos, move_parent.rotation_degrees, move_parent.rotation_degrees, \
	move_parent.scale, listScale, base_move_duration)

func unlist(listPos : Vector3, folderPos : Vector3):
	disable_highlight()
	move(listPos, folderPos, move_parent.rotation_degrees, move_parent.rotation_degrees, \
	move_parent.scale, Vector3.ZERO, base_move_duration)

### MOUSE INTERACTION CALLBACKS

func on_mouse_entered():
	if can_highlight:
		highlight_overlay.visible = true

func on_mouse_exited():
	if can_highlight:
		highlight_overlay.visible = false

func on_mouse_pressed():
	if can_drag_drop:
		counting_drag_drop = true

func on_mouse_released():
	current_drag_drop_time = 0.0
	if is_drag_dropping:
		is_drag_dropping = false
		counting_drag_drop = false
		current_drag_drop_time = 0.0
		current_table_pos = move_parent.position - drag_drop_table_height_offset * Vector3.UP
		return
	elif can_click:
		GameManager.select_document(self)

func _get_drag_camera() -> Camera3D:
	if GameManager.camera_node != null:
		return GameManager.camera_node

	return get_viewport().get_camera_3d()


func _get_cursor_table_position() -> Variant:
	var camera := _get_drag_camera()
	if camera == null:
		return null

	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_normal := camera.project_ray_normal(mouse_pos)

	var table_plane := Plane(Vector3.UP, default_table_pos.y)
	return table_plane.intersects_ray(ray_origin, ray_normal)
	
func _process(delta: float) -> void:
	if counting_drag_drop:
		current_drag_drop_time += delta
		if current_drag_drop_time >= drag_drop_time:
			is_drag_dropping = true
			counting_drag_drop = false
			current_drag_drop_time = 0.0
	if is_drag_dropping:
		var cursor_pos = _get_cursor_table_position()
		if cursor_pos != null:
			var drag_pos: Vector3 = cursor_pos
			drag_pos.y += drag_drop_table_height_offset
			move_parent.position = drag_pos
			current_table_pos = drag_pos