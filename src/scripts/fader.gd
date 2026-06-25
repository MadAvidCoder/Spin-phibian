extends CanvasLayer

@export_category("Respawn Animation")
@export var fade_out_time = 0.2
@export var hold_time = 0.1
@export var fade_in_time = 0.35

@onready var rect = $ColorRect

func fade_out(duration = fade_out_time):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1, duration)
	tween.set_ease(Tween.EASE_OUT)
	await tween.finished

func hold(duration = hold_time):
	await get_tree().create_timer(duration).timeout

func fade_in(duration = fade_in_time):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0, duration)
	tween.set_ease(Tween.EASE_IN)
	await tween.finished
