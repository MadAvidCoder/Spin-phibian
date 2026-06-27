extends CharacterBody2D

enum States {
	GROUND,
	AIR,
	JUMPING,
	FLOATING,
	TONGUING,
	GRAPPLED,
	DEAD,
	GOD,
	PLATFORM_AIR,
}

signal respawned

var state: States = States.AIR
var god_released = false

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
@export var jump_velocity: float = -250.0

const SPEED: float = 200
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var tongue: Node2D = $Tongue
@onready var fader: CanvasLayer = $"../../Fader"
@onready var checkpoint: Checkpoint = $"../StartCheckpoint"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var flag_sfx: AudioStreamPlayer = $"../../Music/FlagSFX"
@onready var squelch_sfx: AudioStreamPlayer = $"../../Music/SquelchSFX"
@onready var anim: AnimationPlayer = $AnimationPlayer

var has_left_floor: bool = false
var cancellable: bool = true

func _ready() -> void:
	global_position = checkpoint.marker.global_position

func set_checkpoint(point: Checkpoint):
	checkpoint.sprite.play("going_down")
	checkpoint = point
	flag_sfx.play()

func _physics_process(delta: float) -> void:
	if state != States.GOD and Input.is_action_just_pressed("god"):
		change_state(States.GOD)
		print("You Wish...")
	process_state(delta)
	move_and_slide()
	
	
	for c in get_slide_collision_count():
		var collision = get_slide_collision(c)
		var rid = collision.get_collider_rid()
		if PhysicsServer2D.body_get_collision_layer(rid) & 0b10000:
			respawn()

func respawn():
	change_state(States.DEAD)
	await fader.fade_out()
	global_position = checkpoint.marker.global_position
	respawned.emit()
	await fader.hold()
	await fader.fade_in()
	change_state(States.AIR)

func on_anchor_clicked(targ_anchor: Anchor):
	if state in [States.GROUND, States.AIR, States.FLOATING, States.JUMPING]:
		if targ_anchor.global_position.distance_to(global_position) <= pull_dist:
			anchor = targ_anchor
			raycast.target_position = to_local(anchor.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				return
			
			change_state(States.TONGUING)
			tongue.extend(func():
				squelch_sfx.pitch_scale = randf_range(0.73, 1.23)
				squelch_sfx.play()
				if state == States.TONGUING: change_state(States.GRAPPLED)
				else: tongue.retract(func(): squelch_sfx.play()))

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
		States.AIR, States.FLOATING, States.JUMPING:
			sprite.play("air")
			sprite.flip_h = sign(velocity.x) == 1
		States.TONGUING:
			sprite.play("grapple")
		States.GROUND:
			sprite.play("idle")
			anim.play("jump_squish")
			cancellable = false
		States.GRAPPLED:
			anchor.on_grabbed()
			has_left_floor = false
		States.DEAD:
			velocity = Vector2.ZERO
			sprite.play("death")
		States.GOD:
			god_released = false
		States.FLOATING:
			sprite.flip_h = sign(velocity.x) == 1

func exit_state():
	match state:
		States.GRAPPLED:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(sprite, "rotation", 0.0, 0.4)
			tongue.retract(func(): squelch_sfx.play())
			
			var offset = global_position - anchor.global_position
			var tangent = Vector2(-offset.y, offset.x).normalized()

			if angular_speed < 0:
				tangent *= -1
			
			velocity = tangent * abs(angular_speed)

func process_state(delta: float):
	match state:
		States.FLOATING:
			if is_on_floor():
				change_state(States.GROUND)
			elif is_on_ceiling() or is_on_wall():
				change_state(States.AIR)
		
		States.JUMPING:
			velocity += gravity * delta
			var input_direction = Input.get_axis("left", "right")

			velocity.x = move_toward(
				velocity.x,
				input_direction * SPEED,
				SPEED * 4.3 * delta
			)

			if input_direction == 1:
				sprite.flip_h = true
				collision_shape.position.x = -3.0
			elif input_direction == -1:
				sprite.flip_h = false
				collision_shape.position.x = 3.0
			
			if is_on_floor():
				change_state(States.GROUND)
		
		States.AIR:
			velocity += gravity * delta
			
			if is_on_floor():
				change_state(States.GROUND)
		
		States.GROUND:
			var input_direction = Input.get_axis("left", "right")
			if input_direction == 1:
				sprite.flip_h = true
				collision_shape.position.x = -3.0
			elif input_direction == -1:
				sprite.flip_h = false
				collision_shape.position.x = 3.0
			velocity.x = input_direction * SPEED
			if not anim.is_playing():
				cancellable = true
			if cancellable:
				if velocity.x != 0:
					anim.play("squish")
				else:
					anim.stop()
			
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
				change_state(States.JUMPING)
				return
			
			if not is_on_floor():
				change_state(States.PLATFORM_AIR)
		
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
			collision_shape.position.x = 3.0
			sprite.rotation = sprite.global_position.direction_to(anchor.global_position).angle() + deg_to_rad(180)
			
			if not is_on_floor() and not has_left_floor:
				has_left_floor = true
				print("left_floor")
			
			#if (is_on_wall() or is_on_ceiling()) and has_left_floor:
				#change_state(States.AIR)
			#if is_on_floor() and has_left_floor:
				#change_state(States.GROUND)
			
			raycast.target_position = to_local(anchor.global_position)
			if raycast.is_colliding():
				change_state(States.AIR)
			
		States.GOD:
			velocity = Vector2(Input.get_axis("left", "right"), Input.get_axis("jump", "down")) * 600
			if god_released == false and !Input.is_action_pressed("god"):
				god_released = true
				print("hi")
			
			if Input.is_action_pressed("god") and god_released:
				change_state(States.AIR)
				print("hellow")
		
		States.PLATFORM_AIR:
			velocity += gravity * delta
			var input_direction = Input.get_axis("left", "right")

			velocity.x = move_toward(
				velocity.x,
				input_direction * SPEED,
				SPEED * 4.3 * delta
			)

			if input_direction == 1:
				sprite.flip_h = true
				collision_shape.position.x = -3.0
			elif input_direction == -1:
				sprite.flip_h = false
				collision_shape.position.x = 3.0
		
			if is_on_floor():
				change_state(States.GROUND)
