extends Area2D
class_name Checkpoint

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("frog"):
		if body.checkpoint != self:
			body.set_checkpoint(self)
			sprite.play("going_up")
		else:
			sprite.play("up")


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "going_up":
		sprite.play("up")
	elif sprite.animation == "going_down":
		sprite.play("down")
