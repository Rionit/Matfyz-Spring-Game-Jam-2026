
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
@export var default_table_rot : Vector3


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


var folder : Folder = null # The folder the document is currently in, null if not in any folder

#How high from the table the document should be when being dragged & dropped
@export var drag_drop_table_height_offset : float = 0.01 

# Time the document needs to be pressed for to start drag & drop
@export var drag_drop_time : float = 0.8
var current_drag_drop_time : float = 0.0

# Scale of the document when it's listed in a folder
@export var listed_scale : Vector3 = Vector3(0.5,0.5,0.5)

@export var drag_drop_stick : float = 40

@export var list_time : float = 0.5

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

func _ready() -> void:
	for field in fields:
		field.document = self
	disable_fields()

func evaluate() -> int:
	var total = 0
	for field in fields:
		if !field.evaluate():
			total += 1
	print("Total mistakes from a document: " + str(total))
	return total

### ENABLE/DISABLE TOGGLES

func enable_fields():
	move_finished.disconnect(enable_fields)
	for field in fields:
		field.receives_input = true
		field.mouse_filter = Control.MOUSE_FILTER_PASS
		field.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
func disable_fields():
	for field in fields:
		field.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		field.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	print("enabled drag drop")
	move_finished.disconnect(enable_drag_drop)
	can_drag_drop = true

func disable_drag_drop():
	print("disabled drag drop")
	can_drag_drop = false

### ACTIONS (SELECT, PUT ON TABLE, STASH, MOVE TO TOP, MOVE FROM TOP)

func change_parent(new_parent : Node3D):
	move_parent.reparent(new_parent)

func disable_fields_except(dont_disable : Field):
	for field in fields:
		if field != dont_disable:
			field.receives_input = false

func select():
	if move_parent.get_parent() == GameManager.table_object && can_drag_drop:
		current_table_pos = move_parent.position
	
	change_parent(GameManager.player_face)

	disable_click()
	disable_highlight()
	move_finished.connect(enable_fields)
	# TODO: Make helpbook offset conditional
	move(move_parent.position, selection_pos + GameManager.helpbook_offset, move_parent.rotation_degrees, selection_rot, move_parent.scale, Vector3.ONE, base_move_duration)

func put_on_table():
	disable_fields()
	change_parent(GameManager.table_object)

	move_finished.connect(enable_drag_drop)
	move_finished.connect(enable_highlight)
	move_finished.connect(enable_click)

	AudioManager.play_sfx("document_place")
	print ("Putting on table, current table pos: ", current_table_pos)
	move(move_parent.position, current_table_pos, move_parent.rotation_degrees, Vector3(-90,0,0), move_parent.scale, Vector3.ONE, base_move_duration)

func stash(folder : Folder):
	change_parent(GameManager.table_object)
	disable_click()
	disable_highlight()
	disable_drag_drop()
	print("Resetting current pos to default table pos: ", default_table_pos)
	current_table_pos = default_table_pos
	move(move_parent.position, folder.position, move_parent.rotation_degrees, Vector3(-90,0,0), move_parent.scale, Vector3.ZERO, base_move_duration)

func move_to_top():
	disable_fields()

	move(move_parent.position, top_look_pos + GameManager.helpbook_offset, move_parent.rotation_degrees, top_look_rot, move_parent.scale, Vector3.ONE, base_move_duration)

func move_from_top():
	move_finished.connect(enable_fields)
	move(move_parent.position, selection_pos + GameManager.helpbook_offset, move_parent.rotation_degrees, selection_rot, move_parent.scale, Vector3.ONE, base_move_duration)

func list(folderPos : Vector3, listPos : Vector3):
	move_finished.connect(enable_highlight)
	move_finished.connect(enable_click)

	move(folderPos, listPos, move_parent.rotation_degrees, Vector3.ZERO, \
	move_parent.scale, listed_scale , list_time)

func unlist(listPos : Vector3, folderPos : Vector3):
	disable_highlight()
	move(listPos, folderPos, move_parent.rotation_degrees, Vector3(-90, 0,0), \
	move_parent.scale, Vector3.ZERO, base_move_duration)

### MOUSE INTERACTION CALLBACKS

func on_mouse_entered():
	print("Mouse entered document area.")
	if can_highlight:
		highlight_overlay.visible = true

func on_mouse_exited():
	print("Mouse exited document area.")
	if can_highlight:
		highlight_overlay.visible = false
	if counting_drag_drop:
		print("Stopped counting drag & drop.")
		counting_drag_drop = false
		current_drag_drop_time = 0.0
	if is_drag_dropping:
		print("ERROR: Mouse exited")
		release_drag_drop()

func on_mouse_pressed():
	print("Mouse pressed!")
	if can_drag_drop:
		print("Enabled counting drag & drop.")
		counting_drag_drop = true

func on_mouse_released():
	print("Mouse released!")
	current_drag_drop_time = 0.0
	if is_drag_dropping:
		print("Stopped drag & drop.")
		release_drag_drop()

		var cursor_folder_object = _get_cursor_folder_object()
		
		if cursor_folder_object != null:
			var folder = cursor_folder_object as Folder
			folder.add(self)
			if folder.opened:
				list(move_parent.position, folder.position + folder.folder_list_start.position + folder.folder_list_offset * (folder.documents.size() - 1))			
			else:
				stash(folder)
		# TODO: Add folder logic
		return
	elif can_click:
		GameManager.select_document(self)

func release_drag_drop():
	GameManager.camera_node.unlocked = true
	is_drag_dropping = false
	counting_drag_drop = false
	current_drag_drop_time = 0.0
	move_parent.position.y -= drag_drop_table_height_offset

	
	current_table_pos = move_parent.position

func on_input_event(event : InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			on_mouse_pressed()
		else:
			on_mouse_released()

func _get_drag_camera() -> Camera3D:
	if GameManager.camera_node != null:
		return GameManager.camera_node

	return get_viewport().get_camera_3d()


func _get_cursor_table_position() -> Variant:
	var camera := _get_drag_camera()
	if camera == null:
		return null

	var mouse_pos := get_tree().root.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)

	var ray_normal := camera.project_ray_normal(mouse_pos)

	var table_1 = GameManager.table_object.global_position
	table_1.y += drag_drop_table_height_offset
	var table_2 = table_1 + Vector3(1,0,0)
	var table_3 = table_1 + Vector3(0,0,1)

	var table_plane := Plane(table_1, table_2, table_3)
	return table_plane.intersects_ray(ray_origin, ray_normal)

func _get_cursor_folder_object() -> Object:
	var camera := _get_drag_camera()
	if camera == null:
		return null

	var mouse_pos := get_tree().root.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_normal := camera.project_ray_normal(mouse_pos)
	var ray_end := ray_origin + ray_normal * 1000.0

	var layer_mask := 1 << (5 - 1)
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, layer_mask)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	return result.get("collider", null)
	
func _process(delta: float) -> void:
	if counting_drag_drop:
		current_drag_drop_time += delta
		if current_drag_drop_time >= drag_drop_time:
			GameManager.camera_node.unlocked = false

			is_drag_dropping = true
			counting_drag_drop = false
			current_drag_drop_time = 0.0
	if is_drag_dropping:
		var cursor_pos = _get_cursor_table_position()

		if cursor_pos != null:
			print("Cursor world position: ", cursor_pos)
			cursor_pos -= GameManager.table_object.global_position

			print("Cursor table position: ", cursor_pos)
			cursor_pos.y = drag_drop_table_height_offset

			var dist = cursor_pos - current_table_pos
			var test = Vector3(dist.x * drag_drop_stick * delta, dist.y * drag_drop_stick * delta / 10.0, dist.z * drag_drop_stick/4.0 * delta)

			move_parent.position += (cursor_pos - current_table_pos) * drag_drop_stick * delta
			print("Setting current table pos, new pos" , move_parent.position) 
			current_table_pos = move_parent.position
