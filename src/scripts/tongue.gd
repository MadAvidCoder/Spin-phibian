extends Node2D

@onready var frog: CharacterBody2D = $".."

@export var tongue_extend_time: float = 0.18
@export var tongue_retract_time: float = 0.1

var tongue_progress: float = 0.0 

func _process(delta: float) -> void:
	queue_redraw()

func extend(x):
	tongue_progress = 0.0
	var tween = create_tween()
	tween.tween_property(self, "tongue_progress", 1.0, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(x)

func retract():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "tongue_progress", 0.0, tongue_retract_time)

func _draw() -> void:
	if tongue_progress != 0.0:
		draw_line(
			Vector2.ZERO,
			to_local(frog.anchor.global_position) * tongue_progress,
			Color("fa6e79"),
			2.0
		)
