extends Area2D
class_name Checkpoint

@onready var marker = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("frog"):
		body.set_checkpoint(self)
