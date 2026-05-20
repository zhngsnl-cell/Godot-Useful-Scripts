extends Node

func use_shader(animation:AnimatedSprite2D)->void:
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
