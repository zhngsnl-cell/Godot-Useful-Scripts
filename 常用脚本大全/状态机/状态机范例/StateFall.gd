extends State

func enter() -> void:
	refresh_speed()
	print("State:Fall")

func exit() -> void:
	pass

func update(delta: float) -> void:
	if player.rvelocity.y >= 0.0:
		animation.play("Fall")
	if Input.is_action_pressed("key_up"):
		animation.play("LookUp")
		animation.frame = 2
	if Input.is_action_just_released("key_up"):
		animation.play("Fall")
	
	if player.is_on_floor():
		state_machine.change_state("Walk")

func physics_update(delta: float) -> void:
	
	move()
	
	player.rvelocity.y += 5.0
	if player.rvelocity.y >= max_y_speed:
		player.rvelocity.y = max_y_speed
	if player.rvelocity.y <= -max_y_speed:
		player.rvelocity.y = -max_y_speed
