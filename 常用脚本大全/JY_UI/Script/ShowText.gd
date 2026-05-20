extends Control
@onready var label: Label = $Label

const opening_text:String = "res://Charts/Text.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open(opening_text,FileAccess.READ)
	var file_text = JSON.parse_string(file.get_as_text())
	if file_text is Dictionary:
		var parent:LevelScene = get_parent()
		var text_array:Array = file_text[str(parent.the_level_index)]
		for i in text_array:
			label.text = i
			var tween = create_tween()
			tween.tween_property(label,"modulate:a",1.0,0.3)
			var delay_tween = create_tween()
			delay_tween.tween_interval(4.5)
			await delay_tween.finished
			var tween1 = create_tween()
			tween1.tween_property(label,"modulate:a",0.0,0.3)
			var delay_tween1 = create_tween()
			delay_tween1.tween_interval(16.0)
			await delay_tween1.finished
