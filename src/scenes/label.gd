extends Label

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
