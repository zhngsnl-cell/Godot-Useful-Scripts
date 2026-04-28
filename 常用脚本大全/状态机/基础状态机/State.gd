extends Node
class_name State

# 类型声明：状态机引用，将在状态机中赋值
var state_machine: StateMachine = null
# 角色节点的引用，可根据实际类型调整（例如 CharacterBody2D）
var character: Node = null

func _ready() -> void:
	# 获取拥有状态机的角色节点（假设状态机是角色的子节点）
	# 这里使用 get_parent().get_parent() 可根据实际场景调整
	character = get_parent().get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
