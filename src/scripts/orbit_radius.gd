@tool
extends Node2D

var radius: float

func _ready() -> void:
	pass
	

func _draw():
	if Engine.is_editor_hint():
		var radius = $"..".orbit_radius
		draw_circle(Vector2.ZERO, radius, Color(0.878, 0.404, 0.078, 0.3), false, 1.5)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
