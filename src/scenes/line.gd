extends Line2D

@onready var anchor =  $"../Area2D"
@onready var player = $"../RigidBody2D"

func _process(_delta: float) -> void:
	var point_0 = anchor.position
	var point_1 = player.position
	points = [point_0, point_1]
