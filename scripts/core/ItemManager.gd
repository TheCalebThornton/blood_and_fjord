extends Node2D
class_name ItemManager

var map_items: Array[MapItem] = []

func get_item_at(grid_pos: Vector2i) -> MapItem:
	for item in map_items:
		if item.grid_position == grid_pos:
			return item
	return null

func add_item(item: MapItem) -> void:
	map_items.append(item)

func remove_item(item: MapItem) -> void:
	map_items.erase(item)
