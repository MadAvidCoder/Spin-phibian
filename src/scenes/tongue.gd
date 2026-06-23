extends Node2D

@onready var frog: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if frog.state == frog.States.GRAPPLED:
		draw_line(
			Vector2.ZERO,
			to_local(frog.anchor.global_position),
			Color("fa6e79"),
			1.0
		)
