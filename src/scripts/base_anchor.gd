extends StaticBody2D
class_name Anchor

@export var orbit_radius: float = 100

var cursor
var frog: CharacterBody2D
var sprite : Sprite2D
var mat : ShaderMaterial

func _ready() -> void:
	cursor = get_tree().get_first_node_in_group("cursor")
	frog = get_tree().get_first_node_in_group("frog")
	for child in get_children():
		if child is Sprite2D:
			sprite = child
			break
	sprite.material = sprite.material.duplicate()
	mat = sprite.material

func _process(delta):
	if cursor.closest_overlapping_anchor == self and frog.state != frog.States.GRAPPLED:
		if position.distance_to(frog.position) <= frog.pull_dist:
			mat.set_shader_parameter("outline_color", Color(1, 1, 1, 1))
		else:
			mat.set_shader_parameter("outline_color", Color(0.8, 0.8, 0.8, 0.5))
	else:
		mat.set_shader_parameter("outline_color", Color(0, 0, 0, 0))

func on_grabbed():
	pass

func on_released():
	pass
