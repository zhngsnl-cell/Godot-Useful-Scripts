class_name State
extends Node

var state_machine:StateMachine = null

var actor:HitBody = null

var to_state:State = null


## 进入状态：先执行自身 _on_enter，再进入初始子状态
func enter() -> void:

	_on_enter()
	
	if to_state:
		to_state.enter()


## 退出状态：先退出子状态，再执行自身 _on_exit
func exit() -> void:
	if to_state:
		to_state.exit()
		to_state = null

	_on_exit()

## 处理帧更新：先执行自身 _on_process，再传递给子状态
func process(delta: float) -> void:
	_on_process(delta)

	if to_state:
		to_state.process(delta)


## 处理物理更新：先执行自身 _on_physics_process，再传递给子状态
func physics_process(delta: float) -> void:
	_on_physics_process(delta)

	if to_state:
		to_state.physics_process(delta)


## 处理输入：先执行自身 _on_input，再传递给子状态
func handle_input(event: InputEvent) -> void:
	_on_input(event)

	if to_state:
		to_state.handle_input(event)


## 向上查找根状态机
func get_state_machine() -> StateMachine:
	var node := get_parent()
	while node != null:
		if node is StateMachine:
			return node as StateMachine
		node = node.get_parent()
	return null


# ==============================================
# 以下是子类可以覆写的方法
# ==============================================

func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass


func _on_process(delta: float) -> void:
	pass


func _on_physics_process(delta: float) -> void:
	pass


func _on_input(event: InputEvent) -> void:
	pass
