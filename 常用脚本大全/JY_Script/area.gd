#这是点击类节拍的占位符，用于debug
extends Area2D

#是否成功
var success:bool = false
var in_range:bool = false
#是否已经向 Detector 上报过结果，防止重复计入
var _reported:bool = false

@onready var animation: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Collision
@onready var sound_hit: AudioStreamPlayer = $SoundHit

#向当前关卡的 Detector 上报命中或未命中
func _report(hit:bool) -> void:
	if _reported:
		return
	_reported = true
	var detector = get_tree().get_first_node_in_group("BeatDetector")
	if detector == null:
		return
	if hit:
		detector.report_hit()
	else:
		detector.report_miss()

func use_shader()->void:
	# 1. 加载着色器文件
	var shader = load("res://Script/Shader/Ripple.gdshader")
	
	# 2. 创建新的 ShaderMaterial
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# 3. （可选）设置着色器的 uniform 参数
	shader_material.set_shader_parameter("speed", 2.0)
	shader_material.set_shader_parameter("circle_color", Color(0.0, 0.729, 0.91, 1.0))
	shader_material.set_shader_parameter("circle_width", 0.3)
	shader_material.set_shader_parameter("circle_intensity", 0.5)
	shader_material.set_shader_parameter("strength", 0.01)
	
	# 4. 将材质赋给节点的 material 属性
	animation.material = shader_material

#禁用shader
func disable_shader()->void:
	var shader = load("res://Script/Shader/Null.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	animation.material = shader_material

#没按到就是miss
func _ready() -> void:
	#一开始禁用碰撞
	collision.disabled = true
	#开始出现
	var tween1 = create_tween()
	tween1.tween_property(animation,"modulate:a",1.0,0.15)
	var delay_tween2 = create_tween()
	delay_tween2.tween_interval(0.15)
	await delay_tween2.finished
	#启用碰撞
	collision.disabled = false
	# 用 Tween 实现 0.5 秒延迟
	var delay_tween = create_tween()
	delay_tween.tween_interval(0.5)
	await delay_tween.finished
	#await get_tree().create_timer(0.5).timeout
	#碰撞结束
	collision.disabled = true
	#没按到就输出miss
	if not success:
		#print("miss")
		animation.modulate = Color(1.0, 0.0, 0.0, 1.0)
		_report(false)
	#禁用shader
	disable_shader()
	#开始淡出
	var tween2 = create_tween()
	tween2.tween_property(animation,"modulate:a",0.0,0.15)
	var delay_tween3 = create_tween()
	delay_tween3.tween_interval(0.15)
	await delay_tween3.finished
	#消失，暂时不用对象池
	queue_free()

#按到就是success

func _on_mouse_entered() -> void:
	if not success:#防止重复触发
		if in_range:
			#启用shader
			use_shader()
			success = true
			sound_hit.play()
			_report(true)
			#print("success")
