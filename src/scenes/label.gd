extends Label

@onready var fader: CanvasLayer = $"../../Fader"
const TITLE_SCREEN = preload("res://scenes/title_screen.tscn")
@onready var freedom_music: AudioStreamPlayer = $"../../Music/FreedomMusic"

var time : float
var started : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()

func start():
	time = 0
	started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started:
		time += delta
		text = format_time(time)

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds) / 60
	var seconds: int = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("frog"):
		started = false
		var tweena = create_tween()
		tweena.tween_property(freedom_music, "volume_db", -80.0, 2.5)
		tweena.tween_callback(freedom_music.stop)
		await get_tree().create_timer(2).timeout
		tweena.set_ease(Tween.EASE_IN)
		await fader.fade_out(1)
		await fader.hold()
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
