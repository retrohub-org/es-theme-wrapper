extends HBoxContainer

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var pos_origin := Vector2(0, 0)
var text_color := Color(1, 1, 1, 1)
var font_path := ""
var font_size := 27

func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"textColor":
				text_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height

func apply_theme():
	if not parsed:
		return
	
	for child in get_children():
		if child.has_method("apply_theme"):
			child.parsed = true
			child.font_path = font_path
			child.font_size = font_size
			child.color = text_color
			child.force_uppercase = true
			child.apply_theme()
		else:
			child.max_width = max(rect_size.y, font_size)

	rect_position = position
	if not font_path.empty():
		var dynamic_font := DynamicFont.new()
		dynamic_font.font_data = load(font_path)
		# TODO: Figure out line spacing as there's no 1:1 translation for Godot
		dynamic_font.size = font_size
		add_font_override("font", dynamic_font)
	
	rect_size = Vector2(1024, 1.25 * font_size)
	pos_origin.x *= rect_size.x
	pos_origin.y *= rect_size.y
	rect_position -= pos_origin
