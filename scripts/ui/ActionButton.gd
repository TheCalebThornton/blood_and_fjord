extends Button
class_name ActionButton

func _ready():
	mouse_entered.connect(func(): grab_focus()) 
