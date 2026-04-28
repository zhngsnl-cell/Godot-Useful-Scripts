class_name Player extends CharacterBody2D

var rvelocity:Vector2 = Vector2.ZERO

var current_bullet:Bullet = Bullet.new(1,false,Bullet.BulletType.POLARSTAR,Bullet.Direction.RIGHT)

@export var inventory:Inventory
@export var state_machine:StateMachine

@onready var animation: PlayerAnimation = $Animation
@onready var animation_arm: AnimatedSprite2D = $AnimationArm

enum Face{
	LEFT,
	RIGHT,
}

enum GunState{
	UP,
	LEFT,
	RIGHT,
	DOWN,
}

var face:Face = Face.RIGHT
var gun_state:GunState = GunState.RIGHT

var max_velocity:Vector2=Vector2(50.0,100.0)
var in_water:bool = false

var on_platform:bool = false
var base_velocity:Vector2 = Vector2.ZERO
var platform_velocity:Vector2 = Vector2.ZERO
var platform:Node2D = null

#转身的函数
func flip()->void:
	if Input.is_action_just_pressed("key_right"):
		animation.scale.x = 1.0
		face = Face.RIGHT
	elif Input.is_action_just_pressed("key_left"):
		animation.scale.x = -1.0
		face = Face.LEFT

func change_gun_state()->void:
	if Input.is_action_just_released("key_up"):
		match face:
			Face.LEFT:
					gun_state = GunState.LEFT
			Face.RIGHT:
				gun_state = GunState.RIGHT
			_:
				pass
	else:
		pass
	if Input.is_action_just_released("key_down"):
		match face:
			Face.LEFT:
					gun_state = GunState.LEFT
			Face.RIGHT:
				gun_state = GunState.RIGHT
			_:
				pass
	else:
		pass
	if Input.is_action_pressed("key_up"):
		gun_state = GunState.UP
	elif Input.is_action_just_pressed("key_down"):
		gun_state = GunState.DOWN
	elif Input.is_action_just_pressed("key_left"):
		gun_state = GunState.LEFT
	elif Input.is_action_just_pressed("key_right"):
		gun_state = GunState.RIGHT

func change_gun_position()->void:
	match gun_state:
		GunState.UP:
			match face:
				Face.LEFT:
					animation_arm.play("WPolarStarUp")
					animation_arm.position = Vector2(-5.0,3.0)
					animation_arm.scale.x = -1.0
					animation_arm.scale.y = 1.0
				Face.RIGHT:
					animation_arm.play("WPolarStarUp")
					animation_arm.position = Vector2(5.0,3.0)
					animation_arm.scale.x = 1.0
					animation_arm.scale.y = 1.0
				_:
					pass
		GunState.DOWN:
			match face:
				Face.LEFT:
					animation_arm.play("WPolarStarUp")
					animation_arm.position = Vector2(-5.0,3.0)
					animation_arm.scale.x = -1.0
					animation_arm.scale.y = -1.0
				Face.RIGHT:
					animation_arm.play("WPolarStarUp")
					animation_arm.position = Vector2(5.0,3.0)
					animation_arm.scale.x = 1.0
					animation_arm.scale.y = -1.0
				_:
					pass
		GunState.LEFT:
			animation_arm.play("WPolarStar")
			animation_arm.position = Vector2(-7.0,3.0)
			animation_arm.scale.x = -1.0
			animation_arm.scale.y = 1.0
		GunState.RIGHT:
			animation_arm.play("WPolarStar")
			animation_arm.position = Vector2(7.0,3.0)
			animation_arm.scale.x = 1.0
			animation_arm.scale.y = 1.0
		_:
			pass

func change_bullet_direction()->void:
	match gun_state:
		GunState.UP:
			current_bullet.direction = Bullet.Direction.UP
		GunState.DOWN:
			current_bullet.direction = Bullet.Direction.DOWN
		GunState.LEFT:
			current_bullet.direction = Bullet.Direction.LEFT
		GunState.RIGHT:
			current_bullet.direction = Bullet.Direction.RIGHT
		_:
			pass

func _process(_delta: float) -> void:
	
	flip()
	change_gun_state()
	change_gun_position()
	change_bullet_direction()
	
	if Input.is_action_just_pressed("test"):
		print(face)
		print(gun_state)
	
	if Input.is_action_just_pressed("key_x"):
		GameEvent.send_shoot_bullet(current_bullet,global_position)

func _physics_process(delta: float) -> void:
	if on_platform:
		velocity = platform.velocity + state_machine.current_state.get_velocity()
		state_machine.current_state.colliding = move_and_slide()
	else:
		velocity = state_machine.current_state.get_velocity()
		state_machine.current_state.colliding = move_and_slide()

func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("MovingPlatform"):
		print("On Platform!")
		on_platform = true
		platform = body
		platform_velocity = platform.velocity

func _on_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("MovingPlatform"):
		print("Off Platform")
		on_platform = false
