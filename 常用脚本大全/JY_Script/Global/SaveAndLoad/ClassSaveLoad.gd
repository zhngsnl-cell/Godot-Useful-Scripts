extends Node

var current_level_index:int = 0

const level_array:Array[String] = [
	"res://Level/Level0.tscn",
	"res://Level/Level1.tscn",
	"res://Level/Level2.tscn",
	"res://Level/Level3.tscn",
	"res://Level/Level4.tscn",
]

func load_level(level_index: int) -> PackedScene:
	if level_index < 0 or level_index >= level_array.size():
		return null
	return load(level_array[level_index])

func goto_level(level_index: int):
	var scene = load_level(level_index)
	if scene:
		get_tree().change_scene_to_packed(scene)

const SAVE_PATH:String = "user://settings.tres"

func _save()->void:
	var data:LevelData = LevelData.new()
	data.level_index = current_level_index
	
	ResourceSaver.save(data,SAVE_PATH)

func _load()->int:
	#修复：首次启动或存档损坏时不再崩溃，按 0 处理
	if not ResourceLoader.exists(SAVE_PATH):
		current_level_index = 0
		return 0
	var data = ResourceLoader.load(SAVE_PATH) as LevelData
	if data == null:
		current_level_index = 0
		return 0
	current_level_index = data.level_index
	return current_level_index
