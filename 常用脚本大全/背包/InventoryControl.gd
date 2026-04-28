extends Control

@export var player:Player

@onready var inventory_grid: GridContainer = $PanelContainer/VBoxContainer/MarginContainer/InventoryGrid
@onready var slot_panel: PanelContainer = $SlotPanel
@onready var title: Label = $PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/Title
@onready var text: Label = $PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/Text

const ARTHUR_S_KEY:Item = preload("res://Item/Arthur's Key.tres")
const DOG:Item = preload("res://Item/Dog.tres")
const NULL:Item = preload("res://Item/Null.tres")

var slot_panel_index:int = 0

#刷新背包物品图像
func refresh_inventory()->void:
	for i:int in range(12):
		var texture:TextureRect = inventory_grid.get_child(i)
		texture.texture = player.inventory.slots[i].item.item_texture
	title.text = player.inventory.slots.get(slot_panel_index).item.item_name
	text.text = player.inventory.slots.get(slot_panel_index).item.description

#选取特定物品
func select()->void:
	if Input.is_action_just_pressed("key_up"):
		if (slot_panel_index - 4) < 0:
			pass
		else:
			slot_panel_index -= 4
			slot_panel.position.y -= 20.0
			refresh_inventory()
	if Input.is_action_just_pressed("key_down"):
		if (slot_panel_index + 4) > 11:
			pass
		else:
			slot_panel_index += 4
			slot_panel.position.y += 20.0
			refresh_inventory()
	if Input.is_action_just_pressed("key_left"):
		if (slot_panel_index % 4) == 0:
			pass
		else:
			slot_panel_index -= 1
			slot_panel.position.x -= 36.0
			refresh_inventory()
	if Input.is_action_just_pressed("key_right"):
		if (slot_panel_index % 4) == 3:
			pass
		else:
			slot_panel_index += 1
			slot_panel.position.x += 36.0
			refresh_inventory()

func _ready() -> void:
	refresh_inventory()

func _process(delta: float) -> void:
	select()
