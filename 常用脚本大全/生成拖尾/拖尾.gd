extends Line2D

@export var point_count:int = 10
@export var isSpawn:bool = false
var left_position:Vector2 = Vector2.ZERO
var right_position:Vector2 = Vector2.ZERO
var parent_node:Node = null
var can_draw_tail:bool = false
var cooldown:float = 2.0
var sum:float = 0.0

func _ready() -> void:
	parent_node = get_parent()
	#print(parent_node.global_position)
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = Vector2.ZERO
	global_rotation = 0.0
	
	if can_draw_tail == false:
		sum += delta
		if sum >= cooldown:
			can_draw_tail = true
			sum = 0.0
	
	if can_draw_tail:
		tail_func()


func draw_point(Lposition:Vector2)->void:
	add_point(Lposition)

func tail_func()->void:
	if isSpawn:
		if get_point_count() > point_count:
			remove_point(0)
		else:
			pass
		draw_point(parent_node.global_position)
		#print(1)
		#draw_point(right_position)
	else:
		if get_point_count() > 0:
			remove_point(0)
		else:
			pass
