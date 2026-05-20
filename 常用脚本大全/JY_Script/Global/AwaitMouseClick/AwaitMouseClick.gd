extends Node

signal miss
signal mouse_clicked

#简易等待鼠标输入，放置需要的地方
func _ready() -> void:
	await mouse_clicked

func _input(event):
	# 只响应鼠标左键按下的动作
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_clicked.emit()

func send_miss()->void:
	miss.emit()
