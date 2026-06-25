extends Anchor
class_name MagmaAnchor

func on_grabbed():
	super.on_grabbed()
	sprite.play("heating")

func _on_animation_finished():
	if sprite.animation == "heating" and is_grabbed:
		frog.respawn()
