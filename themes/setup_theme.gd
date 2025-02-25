extends Theme

func setup_theme() -> Theme:
	var theme = Theme.new()
	
	# Panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(7,87,152)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color("333333")
	panel_style.set_corner_radius_all(4)
	theme.set_stylebox("CharacterStatsPanel", "Panel", panel_style)
	
	# Margin styling
	#var margin_style = StyleBoxFlat.new()
	#margin_style.set_expand_margin_all(8)
	#theme.set_stylebox("MarginContainer", "MarginContainer", margin_style)
	
	# Label defaults
	theme.set_color("font_color", "Label", Color("ffffff"))
	theme.set_font_size("font_size", "Label", 12)
	
	return theme 
