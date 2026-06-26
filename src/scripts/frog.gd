extends CharacterBody2D

enum States {
	GROUND,
	AIR,
	FLOATING,
	TONGUING,
	GRAPPLED,
	DEAD,
}

signal respawned

var state: States = States.AIR

@export_category("Grappling")
@export var pull_strength: float = 600.0
@export var max_pull_speed: float = 450.0
var angular_speed: float = 0
@export var pull_dist: float = 300.0
@export var radial_speed: float = 50
@export var radial_tolerance: float = 5
var angle: float = 0.0

var anchor: Anchor

@export_category("Platforming")
@export var gravity: Vector2 = Vector2(0, 50)

const SPEED: float = 200
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var tongue: Node2D = $Tongue
@onready var fader: CanvasLayer = $"../Fader"
@onready var checkpoint: Checkpoint = $"../StartCheckpoint"

func _ready() -> void:
	global_position = checkpoint.marker.global_position

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		respawn()

func set_checkpoint(point: Checkpoint):
	checkpoint = point

func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func respawn():
	change_state(States.DEAD)
	await fader.fade_out()
	global_position = checkpoint.marker.global_position
	respawned.emit()
	await fader.hold()
	await fader.fade_in()
	change_state(States.AIR)

func on_anchor_clicked(targ_anchor: Anchor):
	if state == States.GROUND or state == States.AIR or state == States.FLOATING:
		if targ_anchor.global_position.distance_to(global_position) <= pull_dist:
			anchor = targ_anchor
			
			change_state(States.TONGUING)
			tongue.extend(func():
				if state == States.TONGUING: change_state(States.GRAPPLED)
				else: tongue.retract())

			var dir = (anchor.global_position - global_position)
			var cross = dir.cross(velocity)
			if cross > 0:
				angular_speed = -abs(anchor.angular_speed)
			else:
				angular_speed = abs(anchor.angular_speed)

func on_anchor_released():
	if state == States.GRAPPLED or state == States.TONGUING:
		anchor.on_released()
		if anchor.type == Anchor.AnchorTypes.RAINBOW:
			change_state(States.FLOATING)
		else:
			change_state(States.AIR)

func change_state(new_state: States):
	exit_state()
	state = new_state
	enter_state()

func enter_state():
	match state:
		States.AIR:
			sprite.play("air")
		States.TONGUING:
			sprite.play("grapple")
		States.GROUND:
			sprite.play("idle")
		States.GRAPPLED:
			anchor.on_grabbed()
		States.DEAD:
			velocity = Vector2.ZERO

func exit_state():
	match state:
		States.AIR:
			pass
		States.GRAPPLED:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(sprite, "rotation", 0.0, 0.4)
			tongue.retract()

func process_state(delta: float):
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
			
			sprite.flip_h = false
			sprite.rotation = sprite.global_position.direction_to(anchor.global_position).angle() + deg_to_rad(180)
