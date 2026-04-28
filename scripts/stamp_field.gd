@tool
extends Field

@export var stamp_on_doc: Texture2D
@export var stamp_at_counter: Texture2D

@onready var black_stamp_texture: TextureRect = $TextureRect
@onready var color_stamp_texture: TextureRect = $TextureRect2

var selected_stamp: Texture2D = null

func _ready() -> void:
	_request_update()
	color_stamp_texture.hide()

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if GameManager.selected_stamp != null and GameManager.selected_document == document and selected_stamp == null:
		selected_stamp = GameManager.selected_stamp
		GameManager.selected_stamp = null
		color_stamp_texture.texture = selected_stamp
		color_stamp_texture.show()

func _update_ui():
	black_stamp_texture.texture = stamp_on_doc

func evaluate() -> bool: # override
	if selected_stamp == null:
		return false
	return selected_stamp == stamp_at_counter
