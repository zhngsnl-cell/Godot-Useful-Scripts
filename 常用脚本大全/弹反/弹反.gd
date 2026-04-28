extends Node
class_name Deflect

var perfect_deflection:float = 0.0
var common_deflection:float = 0.0
var deflection_timer:Timer = null

enum DeflectionType{
	perfect,
	common,
	fail
}

var deflection_type:int
var attack:bool = false

#初始化
func _init(
perfect_deflection_length:float,
common_deflection_length:float,
deflection_timer_node:Timer,
) -> void:
	perfect_deflection = perfect_deflection_length
	common_deflection = common_deflection_length
	deflection_timer = deflection_timer_node
	deflection_timer.wait_time = perfect_deflection

func detect_deflection(deflect_input:String)->int:
	
	if Input.is_action_just_pressed(deflect_input) and deflection_timer.is_stopped():
		deflection_timer.start()
	else:
		pass
	
	if deflection_timer.is_stopped() == false and deflection_timer.time_left >= perfect_deflection:
		if attack == true:
			attack = false
			deflection_timer.stop()
			deflection_type = DeflectionType.perfect
		else:
			pass
	elif deflection_timer.is_stopped() == false:
		if attack == true:
			attack = false
			deflection_timer.stop()
			deflection_type = DeflectionType.common
		else:
			pass
	else:
		deflection_type = DeflectionType.fail
	
	return deflection_type

func get_attack()->void:
	attack = true

func restore()->void:
	attack = false
