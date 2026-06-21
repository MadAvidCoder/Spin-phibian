extends StaticBody2D
class_name Anchor

var frog: CharacterBody2D

func _ready() -> void:
	frog = get_tree().get_first_node_in_group("frog")
	print(frog.name)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		frog.on_anchor_clicked(self)

func on_grabbed():
	pass

func on_released():
	pass
