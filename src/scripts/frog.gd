extends CharacterBody2D

enum States {
	GROUND,
	AIR,
	PULLING,
	ORBITING
}

var state: States = States.AIR

@export_category("Grappling")
@export var orbit_radius: float = 80.0
@export var pull_speed: float = 600.0
@export var angular_speed: float = 12.0
@export var max_grapple_distance: float = 500.0
var angle: float = 0.0


var anchor_pos: Vector2

@export_category("Platforming")
@export var gravity: Vector2 = Vector2(0, 50)

const SPEED: float = 300.0

func _physics_process(delta: float) -> void:
	# HACK: Temporary only
	if Input.is_action_just_pressed("grapple"):
		enter_grapple(get_global_mouse_position())
	if Input.is_action_just_released("grapple"):
		change_state(States.AIR)
	
	process_state(delta)
	move_and_slide()

func change_state(new_state: States):
	exit_state()
	state = new_state
	enter_state()

func enter_grapple(pos: Vector2):
	anchor_pos = pos
	if global_position.distance_to(pos) <= max_grapple_distance:
		change_state(States.PULLING)

func enter_state():
	match state:
		States.AIR:
			pass
		States.ORBITING:
			var offset = global_position - anchor_pos
			angle = offset.angle()
			var tangent = Vector2(-offset.y, offset.x).normalized()
			
			if velocity.dot(tangent) < 0:
				angular_speed = -abs(angular_speed)
			else:
				angular_speed = abs(angular_speed)

func exit_state():
	match state:
		States.AIR:
			pass
		States.ORBITING:
			var tangent = Vector2.RIGHT.rotated(angle + PI / 2)
			velocity = tangent * angular_speed * orbit_radius

func process_state(delta: float):
	match state:
		States.AIR:
			var input_direction = Input.get_axis("left", "right")
			var target_x = input_direction * SPEED
			velocity.x = move_toward(velocity.x, target_x, 2000 * delta)
			velocity += gravity
			if is_on_floor():
				change_state(States.GROUND)
		
		States.GROUND:
			var input_direction = Input.get_axis("left", "right")
			velocity.x = input_direction * SPEED
			
			if not is_on_floor():
				change_state(States.AIR)
		
		States.PULLING:
			var to_anchor = anchor_pos - global_position
			var dist = to_anchor.length()
			
			if dist <= orbit_radius:
				change_state(States.ORBITING)
				return
			
			velocity = to_anchor.normalized() * pull_speed
		
		States.ORBITING:
			angle += angular_speed * delta
			global_position = anchor_pos + Vector2.RIGHT.rotated(angle) * orbit_radius
