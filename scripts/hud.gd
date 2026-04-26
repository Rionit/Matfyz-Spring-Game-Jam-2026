extends Control

@onready var picture: Hand = $Picture

@export var picture_texture: Texture2D

func hide_picture():
	picture.texture = null
	picture.hide_hand()
	
func show_picture():
	picture.texture = picture_texture
	picture.show_hand()
