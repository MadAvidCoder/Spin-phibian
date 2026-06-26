extends Anchor
class_name CrystalAnchor

@export var reset_time: float = 1.5

@onready var timer = $Timer

func _ready():
	super._ready()
	type = AnchorTypes.CRYSTAL
	frog.respawned.connect(_on_frog_respawned)

func on_grabbed():
	super.on_grabbed()
	sprite.play("cracking")
	timer.stop()

func on_released():
	super.on_released()
	sprite.pause()
	timer.start(reset_time)

func _on_animation_finished():
	if sprite.animation == "cracking" and is_grabbed:
		sprite.play("crumble")
		frog.on_anchor_released()
		set_collision_mask_value(3, false)
		timer.start(reset_time)

func _on_timer_timeout():
	sprite.play("idle")
	set_collision_mask_value(3, true)

func _on_frog_respawned():
	sprite.play("idle")
	set_collision_mask_value(3, true)
	timer.stop()
