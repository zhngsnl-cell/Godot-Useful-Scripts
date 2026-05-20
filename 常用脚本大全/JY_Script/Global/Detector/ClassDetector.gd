class_name Detector extends Node

var beat_index:int = 0
var prompt_index:int = 0
var current_bg_background:int
var beat_amount:int = 0
var rest_index:int
var rest_interval:float = 0.0
var last_rest_point:float = 0.0
var time_container:Array[float]
var position_container_x:Array[float]
var position_container_y:Array[float]

var delay:float = 0.2

#命中/未命中统计（由各个检测区域 area.gd 在判定结束时上报）
var success_count:int = 0
var miss_count:int = 0

#准确率过低提示弹窗的阈值（低于该值则在章末弹出"是否重新开始本章"询问）
const ACCURACY_THRESHOLD:float = 0.6

#上报命中
func report_hit() -> void:
	success_count += 1

#上报未命中
func report_miss() -> void:
	miss_count += 1

#当前准确率（0.0 ~ 1.0）。无任何判定时返回 1.0，避免误触发弹窗
func get_accuracy() -> float:
	var total:int = success_count + miss_count
	if total <= 0:
		return 1.0
	return float(success_count) / float(total)

@export var music_player:AudioStreamPlayer
@export var music_score_index:String
@export var rest_point:Array[float]
@export var rest_length:Array[float]
@export var black_sprite:Sprite2D
@export var background:Sprite2D
@export var bg1_index:int
@export var bg2_index:int

var music_score:Dictionary = {
	"0":"res://Charts/intro_chapter1.json",
	"1":"res://Charts/chapter3_bird.json",
	"2":"res://Charts/chapter5_final.json",
}

func set_prompt(position:Vector2)->void:
	var new_area_scene:PackedScene = preload("res://Script/Prompt.tscn")
	var new_area = new_area_scene.instantiate()
	get_parent().add_child(new_area)
	new_area.global_position = position

#放置节拍
func set_area(position:Vector2)->void:
	#加载检测区域
	var new_area_scene:PackedScene = load("res://Script/Area.tscn")
	var new_area = new_area_scene.instantiate()
	get_parent().add_child(new_area)
	#设置位置
	new_area.global_position = position

#读取json文件
func load_music_score(index:String)->void:
	var file = FileAccess.open(music_score[index],FileAccess.READ)
	var file_text = JSON.parse_string(file.get_as_text())
	if file_text is Dictionary:
		var time_array:Array = file_text["notes"]
		beat_amount = time_array.size()
		for i:Dictionary in time_array:
			time_container.append(i["time"]/1000.0)
			position_container_x.append(i["x"] * 3.75)
			position_container_y.append(i["y"] * 2.8175)

func print_progress()->void:
	if Input.is_action_just_pressed("Q"):
		print(beat_index)
		print(beat_amount)

func rest(rest_length:float)->void:
	var tween1 = create_tween()
	tween1.tween_property(black_sprite,"modulate:a",1.0,rest_length/2.0)
	var delay_tween1 = create_tween()
	delay_tween1.tween_interval(rest_length/2.0)
	await delay_tween1.finished
	
	if current_bg_background == bg1_index:
		current_bg_background = bg2_index
		background.texture = GlobalResource.background.get(bg2_index)
	else:
		current_bg_background = bg1_index
		background.texture = GlobalResource.background.get(bg1_index)
	
	var tween2 = create_tween()
	tween2.tween_property(black_sprite,"modulate:a",0.0,rest_length/2.0)
	var delay_tween2 = create_tween()
	delay_tween2.tween_interval(rest_length/2.0)
	await delay_tween2.finished

func _ready() -> void:
	var parent:LevelScene = get_parent()
	print("current level:" + str(parent.the_level_index))
	
	#加入分组，便于 area.gd 通过 group 上报命中/未命中
	add_to_group("BeatDetector")
	
	current_bg_background = bg1_index
	
	background.texture = GlobalResource.background.get(bg1_index)
	
	var tween = create_tween()
	tween.tween_property(black_sprite,"modulate:a",0.0,3.0)
	var delay_tween = create_tween()
	delay_tween.tween_interval(3.0)
	await delay_tween.finished
	
	load_music_score(music_score_index)
	#播放音乐
	music_player.play()
	
	for i in rest_point:
		var delay_tween0 = create_tween()
		delay_tween0.tween_interval(i - last_rest_point)
		await delay_tween0.finished
		#await get_tree().create_timer(i - last_rest_point).timeout
		last_rest_point = i
		rest_interval = rest_length.get(rest_index)
		rest(rest_length.get(rest_index))
		rest_index += 1
	
	await music_player.finished
	
	#章末判定：若准确率低于阈值，弹出 4 秒倒计时询问是否重新开始本章
	var accuracy:float = get_accuracy()
	print("chapter end accuracy: " + str(accuracy) + " (" + str(success_count) + "/" + str(success_count + miss_count) + ")")
	if (success_count + miss_count) > 0 and accuracy < ACCURACY_THRESHOLD:
		var popup:AccuracyPopup = AccuracyPopup.show_for(parent, accuracy)
		var restart:bool = await popup.decision_made
		if restart:
			#玩家选择重新开始本章
			SaveLoad.goto_level(int(parent.the_level_index))
			return
		#选择"否"或倒计时结束 -> 继续走原有过场流程
	
	var tween3 = create_tween()
	tween3.tween_property(black_sprite,"modulate:a",1.0,3.0)
	var delay_tween3 = create_tween()
	delay_tween3.tween_interval(3.0)
	await delay_tween3.finished
	
	var next_level:PackedScene = SaveLoad.load_level(int(parent.the_level_index) + 1)
	if next_level and parent.the_level_index != 4:
		get_tree().change_scene_to_packed(next_level)
	elif parent.the_level_index == 4:
		var end_scene:PackedScene = load("res://UI/Scene/End.tscn")
		get_tree().change_scene_to_packed(end_scene)
	else:
		print("can't find level!")

#暂时不生成节拍
func _process(delta: float) -> void:
	print_progress()
	if prompt_index < beat_amount:
		var current_time = music_player.get_playback_position()
		if current_time >= time_container.get(prompt_index) - 0.4:
			set_prompt(Vector2(position_container_x.get(prompt_index),position_container_y.get(prompt_index)))
			prompt_index += 1
	if beat_index < beat_amount:
		#使用AudioPlayer的时间，如果时间大于检测区域的出现时间，那么生成检测区域
		var current_time = music_player.get_playback_position()
		#减去0.5确保节拍的检测区间与音乐重合
		if current_time >= time_container.get(beat_index) - delay:
			set_area(Vector2(position_container_x.get(beat_index),position_container_y.get(beat_index)))
			#进行到下一个检测区域
			beat_index += 1
