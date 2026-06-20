extends CharacterBody2D

enum States {ground, air, grappled}
var state: States = States.air

@export_category("Platforming")
@export var gravity: Vector2



func _physics_process(delta: float) -> void:
	var input_direction = Input.get_axis("left", "right")
	print(input_direction)
	
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
	pass

func process_state():
	match state:
		States.air:
			velocity += gravity
			if is_on_floor():
				change_state(States.ground)
		
		States.ground:
			pass
