@tool
extends Field

@export var stamp_black: Texture2D:
	set(value):
		stamp_black = value
		_request_update()

@export var stamp_color: Texture2D

@onready var texture_rect: TextureRect = $TextureRect

var selected_stamp: Texture2D = null

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if GameManager.selected_stamp != null and GameManager.selected_document == document:
		selected_stamp = GameManager.selected_stamp

func _update_ui():
	print("hi")
	texture_rect.texture = stamp_black

func evaluate() -> bool: # override
	if selected_stamp == null:
		return false
	return selected_stamp == stamp_color
