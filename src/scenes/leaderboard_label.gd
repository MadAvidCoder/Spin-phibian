extends Label

func _set_pos(pos: int) -> void:
	text = text.replace("{pos}", str(pos + 1))

func _set_username(username: String) -> void:
	text = text.replace("{username}", username)

func _set_score(score: int) -> void:
	text = text.replace("{score}", format_time(score))

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds) / 60
	var seconds: int = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func set_data(pos: int, username: String, score: int) -> void:
	_set_pos(pos)
	_set_username(username)
	_set_score(score)
