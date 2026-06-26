extends Camera2D

@onready var frog: CharacterBody2D = %Frog

@export var camera_speed: float = 6.0
@export var blend_speed: float = 3.0

var focus_position: Vector2
var grapple_blend: float = 0.0

func _process(delta):
	grapple_blend = move_toward(
		grapple_blend,
		1.0 if frog.state == frog.States.GRAPPLED or frog.state == frog.States.TONGUING else 0.0,
		delta * blend_speed
	)
	
	var anchor_pos = frog.anchor.global_position if frog.anchor else frog.global_position
	
	focus_position = frog.global_position.lerp(
		anchor_pos,
		grapple_blend
	)

	global_position = global_position.lerp(
		focus_position,
		camera_speed * delta
	)
