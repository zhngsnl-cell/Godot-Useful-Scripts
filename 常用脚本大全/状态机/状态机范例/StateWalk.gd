extends State

var pressing:bool = false

func play_animation()->void:
	
	if Input.is_action_pressed("key_left") or Input.is_action_pressed("key_right"):
		pressing = true
	else:
		pressing = false
	
	if pressing:
		if Input.is_action_pressed("key_up"):
			animation.play("LookUp")
		elif Input.is_action_just_released("key_up"):
			var frame:int = animation.frame
			animation.play("Walk")
			animation.frame = frame + 1
		elif Input.is_action_just_pressed("key_left"):
			animation.play("Walk")
		elif Input.is_action_just_pressed("key_right"):
			animation.play("Walk")
	else:
		animation.play("Walk")
		animation.stop()
		animation.frame = 1

func enter() -> void:
	print("Sate:Walk")
	animation.play("Walk")
	refresh_speed()

func exit() -> void:
	pass

func update(delta: float) -> void:
	
	#切换跳跃状态
	if Input.is_action_just_pressed("key_z") and player.is_on_floor():
		state_machine.change_state("Jump")
	elif not player.is_on_floor():
		state_machine.change_state("Fall")
	elif pressing == false and player.is_on_floor():
		state_machine.change_state("Idle")
	
	play_animation()

func physics_update(delta: float) -> void:
	
	move()
	
	var direction:float = Input.get_axis("key_left","key_right")
	if direction == 0.0:
		player.rvelocity.x = move_toward(player.rvelocity.x,0.0,delta * 250.0)

func handle_input(event: InputEvent) -> void:
	pass
