extends StaticBody2D
class_name Anchor

@export var orbit_radius: float = 100

var cursor
var frog: CharacterBody2D
var sprite : Sprite2D

func _ready() -> void:
	cursor = get_tree().get_first_node_in_group("cursor")
	frog = get_tree().get_first_node_in_group("frog")
	for child in get_children():
		if child is Sprite2D:
			sprite = child
			break

func process():
	if cursor.closest_overlapping_anchor == self:
		pass

func on_grabbed():
	pass

func on_released():
	pass
