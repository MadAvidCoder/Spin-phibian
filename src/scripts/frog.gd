extends CharacterBody2D

enum States {ground, air, grappled}
var state: States = States.air

@export_category("Platforming")
@export var gravity: Vector2 = Vector2(0, 50)

const SPEED: float = 300.0

func _physics_process(delta: float) -> void:
	process_state()
	move_and_slide()

func change_state(new_state: States):
	exit_state()
	state = new_state
	enter_state()

func enter_state():
	match state:
		States.air:
			pass

func exit_state():
	match state:
		States.air:
			pass

func process_state():
	match state:
		States.air:
			var input_direction = Input.get_axis("left", "right")
			velocity.x = input_direction * SPEED
			velocity += gravity
			if is_on_floor():
				change_state(States.ground)
		
		States.ground:
			var input_direction = Input.get_axis("left", "right")
			velocity.x = input_direction * SPEED
			
			if not is_on_floor():
				change_state(States.air)
