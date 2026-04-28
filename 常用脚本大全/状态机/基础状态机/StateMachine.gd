extends Node
class_name StateMachine

# 当前状态
var current_state: State = null
# 状态字典：状态名 -> State实例
var states: Dictionary[String, State] = {}

func _ready() -> void:
	# 收集所有子节点中类型为 State 的节点
	for child in get_children():
		if child is State:
			var state_name: String = child.name.to_lower()
			states[state_name] = child
			child.state_machine = self
	
	# 设置初始状态（例如 "idle"）
	if states.has("idle"):
		change_state("idle")

func change_state(state_name: String) -> void:
	# 退出当前状态
	if current_state:
		current_state.exit()
	
	# 切换新状态
	current_state = states.get(state_name)
	
	# 进入新状态
	if current_state:
		current_state.enter()
	else:
		push_error("状态不存在: ", state_name)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
