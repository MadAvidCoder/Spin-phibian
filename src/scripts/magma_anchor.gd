extends Anchor
class_name MagmaAnchor

@export var reset_time: float = 1.5

@onready var timer = $Timer

func on_grabbed():
	super.on_grabbed()
	sprite.play("heating")
	timer.stop()

func on_released():
	super.on_released()
	sprite.pause()
	timer.start(reset_time)

func _on_animation_finished():
	if sprite.animation == "heating" and is_grabbed:
		frog.respawn()

func _on_timer_timeout():
	sprite.play("idle")
