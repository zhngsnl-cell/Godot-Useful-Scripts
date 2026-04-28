extends Control
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export_group("UI")
@export var text_box:Label
@export var avatar:TextureRect

@export_group("对话")
@export var main_dialogue:DialogueGroup

var dialogue_index:int = 0
var typing_tween:Tween
var sound_length:int = 0

func append_character(character:String)->void:
	text_box.text += character

func display_next_dialogue()->void:
	
	if dialogue_index >= len(main_dialogue.dialogue_list):
		visible = false
		return
	
	var dialogue := main_dialogue.dialogue_list[dialogue_index]
	
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialogue.content
		dialogue_index += 1
		
		audio_stream_player.stop()
	
	else:
		audio_stream_player.play()
		sound_length = 0
		
		typing_tween = get_tree().create_tween()
		text_box.text = ""
		for character in dialogue.content:
			typing_tween.tween_callback(append_character.bind(character)).set_delay(0.05)
			sound_length += 1
		typing_tween.tween_callback(func():dialogue_index += 1)
		
		avatar.texture = dialogue.avatar
		await get_tree().create_timer(sound_length * 0.05).timeout
		audio_stream_player.stop()
	

func _ready() -> void:
	display_next_dialogue()
	pass

func _on_margin_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		display_next_dialogue()
