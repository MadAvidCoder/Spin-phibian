extends Anchor
class_name SpeedAnchor

func _ready() -> void:
	super._ready()
	type = AnchorTypes.SPEED

func on_grabbed():
	super.on_grabbed()
	sprite.play("hit")

func on_released():
	super.on_released()
	sprite.play("idle")
