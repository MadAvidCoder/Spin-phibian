extends CharacterBody2D

enum States {
	GROUND,
	AIR,
	GRAPPLED,
}

var state: States = States.AIR

@export_category("Grappling")
@export var pull_strength: float = 600.0
@export var max_pull_speed: float = 450.0
@export var angular_speed: float = 200
@export var pull_dist: float = 300.0
@export var radial_speed: float = 50
@export var radial_tolerance: float = 5
var angle: float = 0.0


var anchor: Anchor

@export_category("Platforming")
@export var gravity: Vector2 = Vector2(0, 50)

const SPEED: float = 200
@onready var sprite: AnimatedSprite2D = $Sprite

func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func on_anchor_clicked(targ_anchor: Anchor):
	if state == States.GROUND or state == States.AIR:
		if targ_anchor.global_position.distance_to(global_position) <= pull_dist:
			anchor = targ_anchor
			change_state(States.GRAPPLED)

func on_anchor_released():
	if state == States.GRAPPLED:
		change_state(States.AIR)

func change_state(new_state: States):
	exit_state()
	state = new_state
	enter_state()

func enter_state():
	match state:
		States.AIR:
			pass

func exit_state():
	match state:
		States.AIR:
			pass

func process_state(delta: float):
	queue_redraw()
	match state:
		States.AIR:
			velocity += gravity * delta
			if is_on_floor():
				change_state(States.GROUND)
		
		States.GROUND:
			var input_direction = Input.get_axis("left", "right")
			if input_direction == 1:
				sprite.flip_h = true
			elif input_direction == -1:
				sprite.flip_h = false
			velocity.x = input_direction * SPEED
			
			if not is_on_floor():
				change_state(States.AIR)
		
		States.GRAPPLED:
			
			
			
			var offset = anchor.global_position - global_position
			var dir = offset.normalized()
			
			var dist = offset.length()
			var radial_vel = Vector2.ZERO
			if abs(dist - anchor.orbit_radius) > radial_tolerance:
			
				radial_vel = (offset / sign(dist - anchor.orbit_radius))
			
			var tang_vel = Vector2(-dir.y, dir.x) * -angular_speed
			
			velocity = (radial_vel + tang_vel)
			sprite.rotation = global_position.direction_to(anchor.global_position).angle()

func _draw() -> void:
	if state == States.GRAPPLED:
		draw_line(
			Vector2.ZERO,
			to_local(anchor.global_position),
			Color("fa6e79"),
			2.0
		)
