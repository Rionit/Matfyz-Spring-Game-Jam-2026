@tool
extends Field

@export var stamp: Texture2D

enum ColorType { RED, GREEN, BLUE }

@export var color_type: ColorType = ColorType.RED:
	set(value):
		color_type = value
		_request_update()

@onready var stamp_texture: TextureRect = $TextureRect
@onready var paid_stamp_texture: TextureRect = $TextureRect2

func _ready() -> void:
	paid_stamp_texture.hide()
	_request_update()

func _request_update():
	if not is_inside_tree():
		return
	call_deferred("_update_ui")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if GameManager.selected_payment != null and GameManager.selected_document == document and not paid_stamp_texture.visible:
		paid_stamp_texture.texture = GameManager.selected_payment
		GameManager.selected_payment = null
		paid_stamp_texture.show()
		print(paid_stamp_texture.texture == stamp_texture.texture and paid_stamp_texture.visible)

func _update_ui():
	stamp_texture.texture = stamp
	
	match color_type:
		ColorType.RED:
			stamp_texture.modulate = Color(1, 0, 0, 1)
		ColorType.GREEN:
			stamp_texture.modulate = Color(0.0, 0.642, 0.0, 1.0)
		ColorType.BLUE:
			stamp_texture.modulate = Color(0.264, 0.337, 0.66, 1.0)

func evaluate() -> bool: # override
	return paid_stamp_texture.texture == stamp_texture.texture and paid_stamp_texture.visible
