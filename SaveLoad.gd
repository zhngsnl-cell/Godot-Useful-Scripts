extends Node

var a:int = 0

func _save()->void:
	var config = ConfigFile.new()
	config.set_value("Settings","value",a)
	config.save("user://settings.cfg")
	
	print("saved!")

func _load()->void:
	var config = ConfigFile.new()
	var result =  config.load("user://settings.cfg")
	
	if result:
		a = config.get_value("Settings","value")
		print("load!")
	else:
		printerr("load failed!")
