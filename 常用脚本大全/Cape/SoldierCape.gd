extends Node2D

var point_amout:int = 12

# 点数据
var points:Array[Marker2D] = []
var constraints = []
var point_positions:Array[Vector2] = []
var point_distance:float = 1.0

# 绘制相关
var point_radius = 1
var line_color = Color.WHITE
var cape_width:float = 5.5

# 获取节点
var root:Node2D = null
var player:CharacterBody2D = null

func _ready()->void:
	root = get_parent().get_parent()
	player = get_parent().find_child("Soldier")
	# 初始化5个点，排成一行
	for i in range(point_amout):
		var marker:Marker2D = Marker2D.new()
		root.add_child.call_deferred(marker)
		marker.global_position = Vector2(player.global_position.x + i * point_distance, player.global_position.y)
		points.append(marker)
		point_positions.append(Vector2(player.global_position.x + i * point_distance, player.global_position.y))  # 上一帧位置
	
	# 添加距离约束（每对相邻点）
	for i in range(points.size() - 1):
		constraints.append({
			"a": i,
			"b": i + 1,
			"length": point_distance
		})

func _process(delta)->void:
	# 1. 更新点位置（模拟物理）
	var gravity = Vector2(0, 1500.0)
	var damping = 0.99  # 阻尼系数
	
	for i in range(points.size()):
		var velocity = (points[i].global_position - point_positions[i]) * damping
		var new_pos = points[i].global_position + velocity + gravity * delta * delta
		point_positions[i] = points[i].global_position
		points[i].global_position = new_pos
	
	# 2. 应用约束（多次迭代提高稳定性）
	for _iter:int in range(3):  # 迭代次数
		for constraint in constraints:
			var a = points[constraint.a].global_position
			var b = points[constraint.b].global_position
			var diff = b - a
			var dist = diff.length()
			
			if dist > 0.001:
				var correction = (dist - constraint.length) / dist * 0.5
				var offset = diff * correction
				points[constraint.a].global_position += offset
				points[constraint.b].global_position -= offset
	
	# 3. 固定第一个点
	points[0].global_position = player.global_position - Vector2(0.0,1.0)
	point_positions[0] = player.global_position - Vector2(0.0,1.0)
	
	# 请求重绘
	queue_redraw()

func _draw():
	## 绘制连线
	#for constraint in constraints:
		#var a = points[constraint.a].global_position
		#var b = points[constraint.b].global_position
		#draw_line(a, b, line_color, 2.0)
	
	# 绘制点
	#for i in range(points.size()):
		#if i == 0:
			#draw_circle(points[i].global_position, point_radius, Color.RED)  # 固定点
		#else:
			#draw_circle(points[i].global_position, point_radius, Color.BLUE)
	
	for i in range(points.size()-1,0,-1):
		var packed_array:PackedVector2Array = PackedVector2Array(
			[
				Vector2(points[i].global_position.x - cape_width,points[i].global_position.y),
				Vector2(points[i].global_position.x + cape_width,points[i].global_position.y),
				Vector2(points[i].global_position.x + cape_width,points[i-1].global_position.y),
				Vector2(points[i].global_position.x - cape_width,points[i-1].global_position.y),
			]
		)

		if points[i].global_position.y > points[i - 1].global_position.y:
			draw_colored_polygon(packed_array,Color.BROWN)
		else:
			draw_colored_polygon(packed_array,Color.CRIMSON)

# 点击拖动第一个点
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 检查是否点到第一个点附近
			if points[0].global_position.distance_to(event.position) < 30:
				points[0].global_position = event.position
				point_positions[0] = event.position
