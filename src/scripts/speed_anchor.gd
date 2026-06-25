extends Anchor
class_name SpeedAnchor

func on_grabbed():
	super.on_grabbed()
	sprite.play("hit")

func on_released():
	super.on_released()
	sprite.play("idle")
