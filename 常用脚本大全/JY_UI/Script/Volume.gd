extends HSlider

# 当节点进入场景树时，初始化滑块位置和音量
func _ready():
	# 获取 "Master" 总线的索引
	var bus_index = AudioServer.get_bus_index("Master")
	# 获取当前音量 (单位：分贝 dB)
	var current_volume_db = AudioServer.get_bus_volume_db(bus_index)
	# 将分贝值转换为0.0到1.0的线性值，并设置滑块初始位置
	# db_to_linear 是内置函数，用于将分贝转换为线性能量
	value = db_to_linear(current_volume_db)
	# 连接 value_changed 信号到自定义函数
	value_changed.connect(_on_volume_changed)

# 当滑块值改变时调用此函数
func _on_volume_changed(new_value: float):
	# 将0.0到1.0的滑块线性值转换回分贝值
	var new_volume_db = linear_to_db(new_value)
	# 将新的分贝音量设置到 "Master" 总线上
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_volume_db)
