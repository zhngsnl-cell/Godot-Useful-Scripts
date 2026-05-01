class_name Bullet extends Area2D

enum BulletType{
	POLARSTAR,
	FIREBALL,
}

enum Direction{
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

var level:int
var auot_shoot:bool
var type:BulletType
var direction:Direction
var spawn_position:Vector2

func _init(_level:int,_auto_shoot:bool,_type:BulletType,_direction:Direction) -> void:
	level = _level
	auot_shoot = _auto_shoot
	type = _type
	direction = _direction
