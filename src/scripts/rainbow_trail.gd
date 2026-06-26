extends Line2D

var active : bool = true
var max_points = 50
var frog : CharacterBody2D
func _ready() -> void:
	frog = get_tree().get_first_node_in_group("frog")



func _physics_process(delta: float) -> void:
	if frog.state == frog.States.FLOATING or frog.state == frog.States.GRAPPLED and frog.anchor is RainbowAnchor:
		add_point(frog.position)
		if len(points) > max_points:
			remove_point(0)
	elif len(points) != 0:
		remove_point(0)
	print(len(points))
