extends Node2D

@onready var volcano_music: AudioStreamPlayer = $Music/VolcanoMusic
@onready var concrete_music: AudioStreamPlayer = $Music/ConcreteMusic
@onready var freedom_music: AudioStreamPlayer = $Music/FreedomMusic

func _on_freedom_trigger_body_entered(body: Node2D) -> void:
	concrete_music.stop()
	freedom_music.play()
	var tweena = create_tween()
	tweena.tween_property(volcano_music, "volume_db", -80.0, 1)
	tweena.tween_callback(volcano_music.stop)
	freedom_music.volume_db = -80
	tweena.set_ease(Tween.EASE_IN)
	var tween = create_tween()
	tween.tween_property(freedom_music, "volume_db", 0.0, 2)
	tween.set_ease(Tween.EASE_OUT)

func _on_volcano_trigger_body_entered(body: Node2D) -> void:
	freedom_music.stop()
	volcano_music.play()
	var tweena = create_tween()
	tweena.tween_property(concrete_music, "volume_db", -80.0, 1.6)
	tweena.tween_callback(concrete_music.stop)
	tweena.set_ease(Tween.EASE_IN)
	volcano_music.volume_db = -80
	var tween = create_tween()
	tween.tween_property(volcano_music, "volume_db", 0.0, 2)
	tween.set_ease(Tween.EASE_OUT)
