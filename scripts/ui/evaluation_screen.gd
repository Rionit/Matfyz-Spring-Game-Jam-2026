extends Control

var menu_button : Button
var continue_button : Button

@export var header_label : RichTextLabel

@export var mistakes_text_label : RichTextLabel
@export var documents_unsubmitted_text_label : RichTextLabel

@export var mistakes_value_label : RichTextLabel
@export var max_mistakes_label : RichTextLabel
@export var documents_unsubmitted_value_label : RichTextLabel
@export var max_documents_unsubmitted_label : RichTextLabel

@export var result_text_label : RichTextLabel
@export var result_value_label : RichTextLabel

@export var main_menu_button : Button
@export var next_day_button : Button

@export var main_menu_scene : PackedScene
@export var day_scenes : Array[PackedScene]

@export var background : TextureRect
@export var win_background : Texture
@export var failure_background : Texture
@export var black_background : Texture

func _ready():
	mistakes_text_label.text = "Total mistakes: "
	documents_unsubmitted_text_label.text = "Documents unsubmitted: "
	result_text_label.text = "Result: "

	mistakes_value_label.text = str(GameManager.evaluation_results.mistakes)
	max_mistakes_label.text = " / " + str(GameManager.evaluation_results.max_mistakes)
	documents_unsubmitted_value_label.text = str(GameManager.evaluation_results.unsubmitted_documents)
	max_documents_unsubmitted_label.text = " / " + str(GameManager.evaluation_results.max_unsubmitted_documents)
	result_value_label.text = "Success" if GameManager.evaluation_results.passed else "Failure"
	result_value_label.add_theme_color_override("font_color", Color(0, 1, 0) if GameManager.evaluation_results.passed else Color(1, 0, 0))

	if GameManager.evaluation_results.passed:
		if GameManager.actual_level < day_scenes.size():
			background.texture = win_background
			next_day_button.visible = false
		else:
			background.texture = black_background
	else:
		background.texture = failure_background
		next_day_button.visible = false

	mistakes_text_label.modulate.a = 0
	documents_unsubmitted_text_label.modulate.a = 0
	mistakes_value_label.modulate.a = 0
	max_mistakes_label.modulate.a = 0
	documents_unsubmitted_value_label.modulate.a = 0
	max_documents_unsubmitted_label.modulate.a = 0
	result_text_label.modulate.a = 0
	result_value_label.modulate.a = 0

	main_menu_button.modulate.a = 0
	next_day_button.modulate.a = 0
	background.modulate = Color(0, 0, 0, 1) # Start with a transparent background

func go_to_menu():
	get_tree().change_scene_to_packed(main_menu_scene)

func go_to_next_day():
	if GameManager.actual_level < day_scenes.size():
		get_tree().change_scene_to_packed(day_scenes[GameManager.actual_level])


func animate():
	menu_button.visible = false
	continue_button.visible = false

	mistakes_text_label.visible = false
	documents_unsubmitted_text_label.visible = false

	mistakes_value_label.visible = false
	max_mistakes_label.visible = false
	documents_unsubmitted_value_label.visible = false
	max_documents_unsubmitted_label.visible = false
	result_text_label.visible = false
	result_value_label.visible = false

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(header_label, "modulate:a", 1.0, 0.8)

	tween.tween_property(mistakes_text_label, "modulate:a", 1.0, 0.8)
	tween.parallel().tween_property(documents_unsubmitted_text_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(mistakes_value_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(mistakes_value_label, "modulate:a", 1.0, 0.8)
	tween.parallel().tween_property(documents_unsubmitted_value_label, "modulate:a", 1.0, 0.8)

	tween.tween_property(max_mistakes_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(max_mistakes_label, "modulate:a", 1.0, 0.8)
	tween.parallel().tween_property(max_documents_unsubmitted_label, "modulate:a", 1.0, 0.8)

	tween.tween_property(result_text_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(result_text_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(result_value_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(result_value_label, "modulate:a", 1.0, 0.8)
	tween.parallel.tween_property(background, "modulate", Color(1, 1, 1, 1), 0.8)
	if !GameManager.evaluation_results.passed or GameManager.actual_level >= day_scenes.size():
		tween.parallel().tween_property(header_label, "modulate.a", 0.0, 0.8)

	tween.tween_property(main_menu_button, "modulate:a", 1.0, 0.8)
	if GameManager.evaluation_results.passed and GameManager.actual_level < day_scenes.size():
		tween.parallel().tween_property(next_day_button, "modulate:a", 1.0, 0.8)
