extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween1 = create_tween()
	tween1.tween_property(self,"modulate:a",0.5,0.5)
	var tween2 = create_tween()
	tween2.tween_property(self,"scale",Vector2(1.8,1.8),0.5)
	var delay_tween1 = create_tween()
	delay_tween1.tween_interval(0.5)
	await delay_tween1.finished
	var tween3 = create_tween()
	tween3.tween_property(self,"modulate:a",0.0,0.15)
	var delay_tween2 = create_tween()
	delay_tween2.tween_interval(0.15)
	await delay_tween2.finished
	queue_free()
