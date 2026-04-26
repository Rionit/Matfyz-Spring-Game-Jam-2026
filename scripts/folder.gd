class_name Folder

extends Area3D

@export var documents : Array[DocumentController] = []

@export var folder_list_start : Node3D

@export var folder_list_offset : Vector3 = Vector3 (0.1,0,0)

@export var open_anim_angle : float = 135

@export var open_anim_time : float = 0.4

@export var reorder_time : float = 0.4

@export var front_page : Node3D

@export var open_close_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export var open_close_transition : Tween.TransitionType = Tween.TRANS_QUAD

@export var highlight : MeshInstance3D

var opened : bool = false

var receives_input : bool = true

func add(doc: DocumentController) -> void:
	documents.append(doc)
	doc.folder = self

func add_docs(docs: Array[DocumentController]) -> void:
	for doc in docs:
		add(doc)

func remove(doc: DocumentController) -> void:
	doc.folder = null
	var index = documents.find(doc)
	documents.remove_at(index)

func remove_reorder(doc : DocumentController) -> void:
	var index = documents.find(doc)
	documents.remove_at(index)
	doc.folder = null

	print("Removed document - new size: " + str(documents.size()))

	if documents.size() > 0:
		receives_input = false
		for i in range(index, documents.size()):
			documents[i].move(documents[i].move_parent.position, position + folder_list_start.position + folder_list_offset * i, \
			documents[i].move_parent.rotation, documents[i].move_parent.rotation, \
			documents[i].move_parent.scale, documents[i].move_parent.scale, reorder_time, Tween.EaseType.EASE_OUT)

		await get_tree().create_timer(reorder_time).timeout
		receives_input = true
	else:
		close()
	
func open():
	opened = true
	receives_input = false

	var tween = create_tween()
	tween.set_trans(open_close_transition)
	tween.set_ease(open_close_ease)
	tween.tween_property(front_page, "rotation_degrees:z", open_anim_angle, open_anim_time)

	await tween.finished
	receives_input = true

func close():
	opened = false
	receives_input = false
	var tween = create_tween()
	tween.set_trans(open_close_transition)
	tween.set_ease(open_close_ease)
	tween.tween_property(front_page, "rotation_degrees:z", 0, open_anim_time)

	await tween.finished
	receives_input = true

func list_all():
	var i = 0
	for doc in documents:
		doc.list(position, position + folder_list_start.position + folder_list_offset * i)
		i += 1
	open()

func unlist_all():
	var i = 0
	for doc in documents:
		doc.unlist(position + folder_list_start.position + folder_list_offset * i, position)
		i += 1
	close()
	
func on_mouse_entered():
	print("Mouse entered folder area")
	if receives_input and documents.size() > 0:
		highlight.visible = true

func on_mouse_exited():
	print("Mouse exited folder area")
	if highlight.visible:
		highlight.visible = false

func on_input_event(camera : Node, event : InputEvent, eventPos : Vector3, eventNormal : Vector3, shapeIdx : int):
	if receives_input and event is InputEventMouseButton and !event.pressed:

		print("Press or release! - opened: " + str(opened) + " documents: " + str(documents.size()))
		if opened:
			print("Folder is open - closing!")
			unlist_all()
		elif documents.size() > 0:
			print("Folder is closed - opening!")
			list_all()
		highlight.visible = false
