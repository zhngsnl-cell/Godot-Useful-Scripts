extends Node
class_name State

var state_machine: StateMachine = null
@export var player: Player = null
@export var animation:PlayerAnimation = null

var colliding:bool = false
var max_x_speed:float = 50.0
var max_y_speed:float = 100.0

func move()->void:
	var direction:float = Input.get_axis("key_left","key_right")
	player.rvelocity.x += direction * 5.0
	
	if abs(player.velocity.x) > max_x_speed:
		player.rvelocity.x = sign(player.rvelocity.x) * max_x_speed

func refresh_speed()->void:
	max_x_speed = player.max_velocity.x
	max_y_speed = player.max_velocity.y

func get_velocity()->Vector2:
	return player.rvelocity

func _ready() -> void:
	pass

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
