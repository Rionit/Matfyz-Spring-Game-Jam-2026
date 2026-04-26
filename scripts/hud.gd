extends Control

@onready var picture: Hand = $Picture

@export var picture_texture: Texture2D

var is_hand_hidden = true

func hide_picture():
	is_hand_hidden = true
	picture.texture = null
	picture.hide_hand()
	
func show_picture():
	is_hand_hidden = false
	picture.texture = picture_texture
	picture.show_hand()
