extends CanvasLayer

@export_category("Respawn Animation")
@export var fade_out_time = 1
@export var fade_in_time = 1

@onready var rect = $ColorRect

func fade_out(duration = fade_out_time):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1, duration)
	await tween.finished

func fade_in(duration = fade_in_time):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0, duration)
	await tween.finished
