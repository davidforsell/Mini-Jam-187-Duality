extends Node

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	var rng = RandomNumberGenerator.new()
	
	var dim = get_viewport().get_visible_rect().size
	
	number.global_position = Vector2(position.x + rng.randi_range(int(-dim.y/32), int(dim.y/32)), position.y + rng.randi_range(int(-dim.y/32), int(dim.y/32)))
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if is_critical:
		color = "#B22"
	if value == 0:
		color = "#FFF8"

	number.label_settings.font_color = color
	
	number.label_settings.font_size = rng.randi_range(dim.y/10, dim.y/10 + 20)
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
	
