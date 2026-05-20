extends Node

func tween_example(animation:AnimatedSprite2D)->void:
	#创建补帧
	var tween = create_tween()
	tween.tween_property(animation,"modulate:a",1.0,0.15)
	#给补帧一个执行的时间
	var delay_tween = create_tween()
	delay_tween.tween_interval(0.15)
	await delay_tween.finished
