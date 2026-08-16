class_name StateMachine
extends Node

var actor:HitBody = null

## 根状态机的初始状态（直接子状态）
@export var initial_state: State

## 当前激活的直接子状态
var current_state: State = null

var from_state:State = null

##状态字典
var states: Dictionary[String, State] = {}


##添加可执行状态
func add_state(state:State)->void:
	state.state_machine = self
	if state.get_child_count():
		for child_state:State in state.get_children():
			add_state(child_state)
	else:
		var state_name: String = state.name
		states[state_name] = state

##设置父状态
func set_parent_state(state:State)->State:
	state.actor = get_parent()
	if state.get_parent() is State:
		var parent_state:State = state.get_parent()
		parent_state.to_state = state
		set_parent_state(parent_state)
		return null
	else:
		from_state = state
		return 

func _ready() -> void:
	# 如果没有手动指定 initial_state，则自动选择第一个 State 子节点
	for state:State in self.get_children():
		add_state(state)

	if initial_state:
		change_state_by_name(initial_state.name)
	

func _process(delta: float) -> void:
	if from_state:
		from_state.process(delta)


func _physics_process(delta: float) -> void:
	if from_state:
		from_state.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if from_state:
		from_state.handle_input(event)


## 根据名称切换根级状态。会退出当前状态然后进入新状态
func change_state_by_name(new_state_name: String) -> void:
	var new_state:State = states[new_state_name]
	
	if new_state == null or new_state == current_state:
		print("change state failed!")
		return
	
	if current_state:
		from_state.exit()
	
	set_parent_state(new_state)
	
	current_state = new_state
	from_state.enter()
