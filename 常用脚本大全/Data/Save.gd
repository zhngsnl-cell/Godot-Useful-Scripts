extends Node

var a:int = 0

func _save()->void:
	var data:SaveData = SaveData.new()
	data.current_level = 1
	data.current_respawn_point = 2
	
	ResourceSaver.save(data,"user://settings.tres")

func _load()->void:
	var data = ResourceLoader.load("user://settings.tres") as SaveData
	a = data.current_level
