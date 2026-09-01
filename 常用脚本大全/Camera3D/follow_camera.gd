extends Camera3D

@export var target: Node3D  # 要跟随的目标（通常是玩家角色）
@export var distance: float = 5.0  # 相机与目标的距离
@export var rotation_speed: float = 0.005  # 鼠标旋转速度
@export var min_pitch: float = -80.0  # 最小俯仰角（向下看）
@export var max_pitch: float = 80.0  # 最大俯仰角（向上看）

var yaw: float = 0.0  # 水平旋转角度
var pitch: float = 0.0  # 垂直旋转角度

func _ready() -> void:
	if target == null:
		push_error("请设置target目标节点！")
		return
	
	# 初始化相机的初始角度
	var initial_rotation = global_rotation_degrees
	yaw = initial_rotation.y
	pitch = initial_rotation.x
	
	# 捕捉鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# 处理鼠标移动事件
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# 更新旋转角度
		yaw -= event.relative.x * rotation_speed
		pitch -= event.relative.y * rotation_speed
		
		# 限制俯仰角度，防止相机翻转
		pitch = clamp(pitch, min_pitch, max_pitch)
	
	# 按ESC释放鼠标
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if target == null:
		return
	
	# 计算相机位置
	var camera_offset = Vector3(
		distance * cos(deg_to_rad(pitch)) * sin(deg_to_rad(yaw)),
		distance * sin(deg_to_rad(-pitch)),
		distance * cos(deg_to_rad(pitch)) * cos(deg_to_rad(yaw))
	)
	
	# 设置相机位置
	global_position = target.global_position + camera_offset
	
	# 让相机看向目标
	look_at(target.global_position, Vector3.UP)
