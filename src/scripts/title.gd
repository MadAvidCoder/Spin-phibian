extends CanvasLayer

var played = false
@onready var button = $PlayButton
@onready var frog: AnimatedSprite2D = $Sprite
@onready var marker: Marker2D = $PlayButton/Marker2D

var progress = 0.0
var orbit_radius = 0.0
@export var orbit_speed: float = 4.0
@export var tongue_extend_time: float = 0.18
var tongue_progress: float = 0.0

const MAIN = preload("uid://b25a2beyym67k")

func _ready() -> void:
	orbit_radius = (frog.global_position - marker.global_position).length()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	if played:
		progress -= delta * orbit_speed
		
		var offset = Vector2(
			cos(progress),
			sin(progress),
		) * orbit_radius
		
		frog.global_position = marker.global_position + offset
		frog.rotation = frog.global_position.direction_to(marker.global_position).angle() + deg_to_rad(180)
		
		var screen_height = get_viewport().size.y
		var frog_pos = frog.global_position * frog.get_viewport_transform()
		if frog_pos.y > screen_height:
			print(frog.global_position.y)
			print(screen_height)
			played = false
			frog.retract(func(): get_tree().change_scene_to_packed(MAIN))

func _on_play_button_pressed() -> void:
	button.disabled = true
	frog.play("grapple")
	frog.extend(func(): played = true)
