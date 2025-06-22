extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $Damagebar

var health = 0

func set_health(new_health):
	health = min(max_value, new_health)
	value = health
	damage_bar.value = health

func set_health_with_timer(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	
	if health < prev_health:
		damage_bar.value = prev_health
		value = health
		timer.start()
	else:
		if get_tree():
			var tween = get_tree().create_tween()
			tween.tween_property(
				self, "value", health, 0.5
				).set_ease(Tween.EASE_OUT)

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health
