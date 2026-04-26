extends Control

@onready var red: Button = %Red
@onready var green: Button = %Green
@onready var blue: Button = %Blue

@onready var red_holder: Control = %RedHolder
@onready var green_holder: Control = %GreenHolder
@onready var blue_holder: Control = %BlueHolder

var holders: Array[Control]
var tweens: Array[Tween] = []

func _ready():
	holders = [red_holder, green_holder, blue_holder]

	red.pressed.connect(func(): _select_payment(GameManager.PaymentType.RED))
	green.pressed.connect(func(): _select_payment(GameManager.PaymentType.GREEN))
	blue.pressed.connect(func(): _select_payment(GameManager.PaymentType.BLUE))

	await get_tree().process_frame

	for h in holders:
		h.pivot_offset = h.size * 0.5
		h.scale = Vector2.ZERO
		h.modulate.a = 0.0

		var btn := h.get_child(0) as Button
		btn.pressed.connect(_hide_all)
		btn.mouse_entered.connect(func(): _hover_in(h))
		btn.mouse_exited.connect(func(): _hover_out(h))

	show_buttons()

func _select_payment(type):
	GameManager.selected_payment = type

	print("Button selected:", GameManager.PaymentType.keys()[type])
	print("GameManager.selected_payment is now:", GameManager.PaymentType.keys()[GameManager.selected_payment])

	hide_buttons()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			show_buttons()

func _kill_tweens():
	for t in tweens:
		if t and t.is_running():
			t.kill()
	tweens.clear()

func show_buttons():
	if GameManager.selected_document == null:
		return
	
	_kill_tweens()

	for h in holders:
		h.visible = true

		var t = create_tween()
		t.tween_property(h, "scale", Vector2.ONE, 0.25)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(h, "modulate:a", 1.0, 0.25)

		tweens.append(t)

func hide_buttons():
	_kill_tweens()

	for h in holders:
		var t = create_tween()
		t.tween_property(h, "scale", Vector2.ZERO, 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)
		t.parallel().tween_property(h, "modulate:a", 0.0, 0.2)

		tweens.append(t)

func _hover_in(h: Control):
	var t = create_tween()
	t.tween_property(h, "scale", Vector2.ONE * 1.1, 0.12)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tweens.append(t)

func _hover_out(h: Control):
	var t = create_tween()
	t.tween_property(h, "scale", Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tweens.append(t)

func _hide_all():
	hide_buttons()

func _on_area_3d_mouse_exited() -> void:
	pass
