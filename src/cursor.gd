extends Area2D

signal anchor_clicked(anchor: Anchor)
var closest_overlapping_anchor : Anchor


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	closest_overlapping_anchor = null
	var min_distance = 10000
	for body in get_overlapping_bodies():
		if body is Anchor:
			var dist_squared = position.distance_squared_to(body.position)
			if dist_squared < min_distance:
				min_distance = dist_squared
				closest_overlapping_anchor = body
	
	if Input.is_action_just_pressed("grapple"):
		if closest_overlapping_anchor != null:
			anchor_clicked.emit(closest_overlapping_anchor)
			print(closest_overlapping_anchor.name)
