extends StaticBody2D
class_name Anchor

@export var orbit_radius: float = 30.0

var frog: CharacterBody2D
var sprite : Sprite2D

func _ready() -> void:
	frog = get_tree().get_first_node_in_group("frog")
	for child in get_children():
		if child is Sprite2D:
			sprite = child
			break

func process():
	pass

func on_grabbed():
	pass

func on_released():
	pass
