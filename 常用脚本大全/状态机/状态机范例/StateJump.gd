extends State

var can_jump:bool = true
var jump_time:float = 0.0
const max_jump_time:float = 0.35

func enter() -> void:
	refresh_speed()
	print("State:Jump")
	animation.play("Jump")
	can_jump = true
	jump_time = 0.0

func exit() -> void:
	pass

func update(delta: float) -> void:
	
	if Input.is_action_pressed("key_up"):
		animation.play("LookUp")
		animation.frame = 0
	if Input.is_action_just_released("key_up"):
		animation.play("Jump")
	
	if Input.is_action_just_released("key_z"):
		state_machine.change_state("Fall")

func physics_update(delta: float) -> void:
	
	var direction:float = Input.get_axis("key_left","key_right")
	
	move()
	
	if Input.is_action_pressed("key_z"):
		if can_jump:
			player.rvelocity.y = -100.0
			jump_time += delta
			if jump_time >= max_jump_time:
				can_jump = false
				jump_time = 0.0
				state_machine.change_state("Fall")

func handle_input(event: InputEvent) -> void:
	pass
