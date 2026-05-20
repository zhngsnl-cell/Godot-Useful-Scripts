extends CanvasLayer

var pausing:bool = false
@onready var control: Control = $Control
@onready var text: Control = $Text
@onready var label: Label = $Text/Label
@onready var volume: VBoxContainer = $Control/Volume
@onready var sound_pause: AudioStreamPlayer = $SoundPause
@onready var sound_hang: AudioStreamPlayer = $SoundHang

const pause_button_texture = preload("res://播放按钮.png")
const play_button_texture = preload("res://暂停按钮.png")

var entrance_scene = load("res://UI/Scene/UIEntrance.tscn")

func pause()->void:
	sound_pause.play()
	control.visible = true
	get_tree().paused = true

func resume()->void:
	control.visible = false
	text.visible = true
	label.text = "3"
	await get_tree().create_timer(1.0).timeout
	label.text = "2"
	await get_tree().create_timer(1.0).timeout
	label.text = "1"
	await get_tree().create_timer(1.0).timeout
	text.visible = false
	get_tree().paused = false

func exit()->void:
	#修复：主菜单等非关卡场景下不该访问 LevelScene，用 as 转换并判空
	var parent_node = get_parent()
	var level_parent:LevelScene = parent_node as LevelScene
	if level_parent != null:
		SaveLoad.current_level_index = level_parent.the_level_index
		SaveLoad._save()
	get_tree().paused = false
	get_tree().change_scene_to_packed(entrance_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause()

func _on_button_resume_button_up() -> void:
	resume()

func _on_button_exit_button_up() -> void:
	call_deferred("exit")

#func _on_button_button_up() -> void:
	#if pause_button.texture == pause_button_texture:
		#pause_button.texture = play_button_texture
		#resume()
		#pause_button.visible = true
	#else:
		#pause_button.texture = pause_button_texture
		#pause()
		#pause_button.visible = true


func _on_button_options_button_up() -> void:
	if volume.visible == false:
		volume.visible = true
	else:
		volume.visible = false

func _on_button_resume_mouse_entered() -> void:
	sound_hang.play()

func _on_button_options_mouse_entered() -> void:
	sound_hang.play()

func _on_button_exit_mouse_entered() -> void:
	sound_hang.play()
