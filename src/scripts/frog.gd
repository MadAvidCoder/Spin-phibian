extends CharacterBody2D

enum States {
	GROUND,
	AIR,
	PULLING,
	ORBITING
}

var state: States = States.AIR

@export_category("Grappling")
@export var pull_strength: float = 600.0
@export var max_pull_speed: float = 450.0
@export var angular_speed: float = 12.0
@export var pull_dist: float = 200.0

var angle: float = 0.0


var anchor: Anchor

@export_category("Platforming")
@export var gravity: Vector2 = Vector2(0, 50)

const SPEED: float = 300.0

func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func on_anchor_clicked(targ_anchor: Anchor):
	if state == States.GROUND or state == States.AIR:
		if targ_anchor.global_position.distance_to(global_position) <= targ_anchor.orbit_radius + pull_dist:
			anchor = targ_anchor
			print(anchor.global_position)
			change_state(States.PULLING)

func on_anchor_released():
	if state == States.ORBITING or state == States.PULLING:
		change_state(States.AIR)

func change_state(new_state: States):
	exit_state()
	state = new_state
	enter_state()

func enter_state():
	match state:
		States.AIR:
			pass
		States.ORBITING:
			var offset = global_position - anchor.global_position
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
			velocity = tangent * angular_speed * anchor.orbit_radius

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
			var to_anchor = anchor.global_position - global_position
			var dist = to_anchor.length()
			
			if dist <= anchor.orbit_radius:
				change_state(States.ORBITING)
				return
			
			velocity += to_anchor.normalized() * pull_strength
			velocity = velocity.limit_length(max_pull_speed)
		
		States.ORBITING:
			angle += angular_speed * delta
			global_position = anchor.global_position + Vector2.RIGHT.rotated(angle) * anchor.orbit_radius
