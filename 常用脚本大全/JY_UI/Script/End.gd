extends Node2D
@onready var s鸣谢: Sprite2D = $S鸣谢

func _ready() -> void:
	await GlobalControl.mouse_clicked
	s鸣谢.visible = true
	await GlobalControl.mouse_clicked
	get_tree().change_scene_to_file("res://UI/Scene/UIEntrance.tscn")
