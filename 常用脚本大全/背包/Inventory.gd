class_name Inventory extends Resource

const null_item:Item = preload("res://Item/Null.tres")

@export var slots:Array[Slot]

func add_item(item:Item)->void:
	for slot:Slot in slots:
		if slot.item == null_item:
			slot.item = item
			break
		else:
			pass

func find_item(item:Item)->Item:
	for slot:Slot in slots:
		if slot.item.item_name == item.item_name:
			return slot.item
	return null_item

func delete_item(item:Item)->void:
	for slot:Slot in slots:
		if slot.item.item_name == item.item_name:
			slot.item = null_item
			break
