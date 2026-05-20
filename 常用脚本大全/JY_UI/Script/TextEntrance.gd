extends CanvasLayer
@onready var label: Label = $Label

const opening_text:String = "res://Charts/开幕文本.json"

func show_text(text:String)->void:
	label.text = text

func _ready() -> void:
	var file = FileAccess.open(opening_text,FileAccess.READ)
	var file_text = JSON.parse_string(file.get_as_text())
	if file_text is Dictionary:
		var text_array:Array = file_text["notes"]
		for i in text_array:
			show_text(i)
			var tween = create_tween()
			tween.tween_property(label,"modulate:a",1.0,0.5)
			await get_tree().create_timer(2.5).timeout
			var tween1 = create_tween()
			tween1.tween_property(label,"modulate:a",0.0,0.5)
			await get_tree().create_timer(0.5).timeout
			print(i)
		await GlobalControl.mouse_clicked
		get_tree().change_scene_to_file("res://UI/Scene/UIEntrance.tscn")
