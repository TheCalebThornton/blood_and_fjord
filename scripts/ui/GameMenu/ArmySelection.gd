extends GridContainer
class_name ArmySelection

@onready var unlockable_manager: UnlockableManager = $"/root/Main/GameManager/UnlockableManager"

var is_unlocked: bool = false

func init_armies():
	await clear_children()
	var unlocked_armies = unlockable_manager.get_unlocked_armies()
	var locked_armies = unlockable_manager.get_locked_armies()
	
	for army:UnlockableArmy in unlocked_armies:
		draw_army(army, true)
	
	for army:UnlockableArmy in locked_armies:
		# For locked armies, show question mark
		draw_army(army, false)

func draw_army(army: UnlockableArmy, isUnlocked: bool):
	var army_container = ArmyOption.new(army, isUnlocked)
	army_container.custom_minimum_size = Vector2(180, 180)
	var label = Label.new()
	var unit_container = HBoxContainer.new()
	self.add_child(army_container)
	army_container.add_child(label)
	army_container.add_child(unit_container)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	
	if isUnlocked:
		label.text = army.army_name
		for unit in army.units:
			var texture_rect = TextureRect.new()
			var u_class = GameUnit.UnitClass.keys()[unit.unit_class]
			var preload_string = "res://assets/Factions/Knights/Troops/%s/%s/portrait.png" % [u_class, unit.sprite_color]
			texture_rect.texture = load(preload_string)
			texture_rect.custom_minimum_size = Vector2(army_container.size.x / army.units.size(), army_container.size.y - 40)
			texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			# TODO: Load proper unit portrait based on unit class and color
			unit_container.add_child(texture_rect)
	else:
		label.text = "???"
		var texture_rect = TextureRect.new()
		texture_rect.texture = preload("res://assets/UI/Icons/question_mark_block.png")
		texture_rect.custom_minimum_size = Vector2(army_container.size.x, army_container.size.y - 40)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED 
		unit_container.add_child(texture_rect)

func clear_children() -> void:
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame # wait one frmae to mark nodes for deletion
	await get_tree().process_frame # wait another frame to actually delete the nodes
