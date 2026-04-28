extends State

# 假设角色有 speed 属性和 AnimationPlayer
# 使用 @onready 获取节点，并标注类型
@onready var animation_player: AnimationPlayer = get_parent().get_node("AnimationPlayer")
@onready var character_body: CharacterBody2D = get_parent() as CharacterBody2D

func enter() -> void:
	animation_player.play("idle")

func physics_update(delta: float) -> void:
	# 检查水平输入
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		state_machine.change_state("walk")
	
	# 检查跳跃
	if Input.is_action_just_pressed("ui_up") and character_body.is_on_floor():
		state_machine.change_state("jump")
