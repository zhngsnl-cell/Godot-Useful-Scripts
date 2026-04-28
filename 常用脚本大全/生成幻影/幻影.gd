extends Node
var velocity
var rushing

func _on_timer_trail_timeout() -> void:
	if velocity == Vector2.ZERO:
		return
	elif rushing == false:
		return
	else:
		pass
	
	var trail:AnimatedSprite2D = preload("res://场景/jet_trail.tscn").instantiate() as AnimatedSprite2D
	get_parent().add_child(trail)
	get_parent().move_child(trail,get_index())
	
	trail.sprite_frames = animated_sprite_2d.sprite_frames
	trail.animation = animated_sprite_2d.animation
	trail.centered = false
	trail.offset = animated_sprite_2d.offset
	trail.global_position = animated_sprite_2d.global_position
	trail.global_rotation = animated_sprite_2d.global_rotation
