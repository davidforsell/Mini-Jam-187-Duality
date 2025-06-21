extends RichTextLabel

var value = 0

func increment():
	value += 1
	_update_text()

func set_value(new_value):
	if new_value < 0:
		return
	value = new_value
	_update_text()

func _update_text():
	text = String(value)

func decrement():
	if value == 0:
		return
	value -= 1
	_update_text()
