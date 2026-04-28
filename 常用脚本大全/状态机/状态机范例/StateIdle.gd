extends State

func enter() -> void:
	refresh_speed()
	print("State:Idle")
	animation.play("Idle")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	
	if Input.is_action_pressed("key_up"):
		animation.play("LookUp")
		animation.frame = 1
	else:
		animation.play("Idle")
	
	var direction:float = Input.get_axis("key_left","key_right")
	if direction != 0.0:
		state_machine.change_state("Walk")
	elif Input.is_action_just_pressed("key_z") and player.is_on_floor():
		state_machine.change_state("Jump")
	elif not player.is_on_floor():
		state_machine.change_state("Fall")
	else:
		pass

func physics_update(delta: float) -> void:
	var direction:float = Input.get_axis("key_left","key_right")
	if direction == 0.0:
		player.rvelocity.x = move_toward(player.rvelocity.x,0.0,delta * 250.0)

func handle_input(event: InputEvent) -> void:
	pass
