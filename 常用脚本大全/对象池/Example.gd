extends Node

var example_bullet:Bullet = Bullet.new(1,false,Bullet.BulletType.POLARSTAR,Bullet.Direction.RIGHT)
var bullet_pool:GenericObjectPool
var animation_fire_pool:GenericObjectPool

#connect函数将信号链接到回调函数_on_shoot_bullet上
func _ready() -> void:
	
	GameEvent.shoot_bullet.connect(_on_shoot_bullet)
	
	# 创建一个专门的节点来存放所有子弹
	var bullet_container:Node2D = Node2D.new()
	bullet_container.name = "BulletContainer"
	add_child(bullet_container)
	bullet_pool = GenericObjectPool.new(preload('res://Scenes/Bullet/bullet_1_l_1.tscn'),bullet_container,50)
	
	var animation_fire_container:Node2D = Node2D.new()
	animation_fire_container.name = "AnimationFireContainer"
	add_child(animation_fire_container)
	animation_fire_pool = GenericObjectPool.new(preload("res://Scenes/Animations/animation_fire.tscn"),animation_fire_container,10)
	
	#print(bullet_pool.get_active_count())
	#print(bullet_pool.get_pool_count())

#回调函数，每次收到信号就会 自动 触发
func _on_shoot_bullet(bullet:Bullet,spawn_position:Vector2)->void:
	example_bullet = bullet
	match bullet.type:
		Bullet.BulletType.POLARSTAR:
			match bullet.level:
				1:
					shoot_bullet_1_l_1(bullet.direction,spawn_position)
				2:
					pass
				3:
					pass
		Bullet.BulletType.FIREBALL:
			pass

func shoot_bullet_1_l_1(direction:Bullet.Direction,spawn_position:Vector2)->void:
	bullet_pool.get_instance().setup(direction,spawn_position,bullet_pool)
	animation_fire_pool.get_instance().setup(spawn_position,animation_fire_pool)
