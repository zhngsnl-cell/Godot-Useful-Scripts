extends CanvasLayer

@onready var volume: VBoxContainer = $Control/Volume
@onready var tutorial: TextureRect = $Control/PanelContainer/Tutorial
@onready var color_rect: ColorRect = $ColorRect
@onready var buttons: Control = $Control/Buttons
@onready var sound_hang: AudioStreamPlayer = $SoundHang

func start_game()->void:
	tutorial.visible = true
	buttons.visible = false
	await GlobalControl.mouse_clicked
	var idx:int = SaveLoad._load()
	#修复：越界时回到 Level0，避免点击开始后无响应
	if SaveLoad.load_level(idx) == null:
		idx = 0
		SaveLoad.current_level_index = 0
		SaveLoad._save()
	SaveLoad.goto_level(idx)

func exit()->void:
	SaveLoad._save()
	get_tree().quit()

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect,"modulate:a",0.0,2.0)
	await get_tree().create_timer(2.0).timeout
	color_rect.visible = false

func _on_button_exit_button_up() -> void:
	exit()

func _on_button_start_button_up() -> void:
	start_game()
	print("start")

func _on_button_options_button_up() -> void:
	if volume.visible == false:
		volume.visible = true
	else:
		volume.visible = false

func _on_button_options_mouse_entered() -> void:
	sound_hang.play()

func _on_button_exit_mouse_entered() -> void:
	sound_hang.play()

func _on_button_start_mouse_entered() -> void:
	sound_hang.play()
