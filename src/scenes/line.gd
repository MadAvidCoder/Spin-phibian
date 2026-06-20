extends Line2D

@onready var anchor =  $"../AnchorBody"
@onready var player = $"../PlayerBody"

func _process(_delta: float) -> void:
	var point_0 = anchor.position
	var point_1 = player.position
	points = [point_0, point_1]
