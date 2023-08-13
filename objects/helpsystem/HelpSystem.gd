extends HBoxContainer

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
@export var es_position := Vector2(0, 0)
var es_pos_origin := Vector2(0, 0)
var es_text_color := Color(1, 1, 1, 1)
var es_font_path := ""
var es_font_size : float = 0.045 * min(PropertyWrapper.screen_width, PropertyWrapper.screen_height)

func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				es_position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				es_pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"textColor":
				es_text_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				es_font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				es_font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height

func apply_theme():
	if not parsed:
		return
	
	for child in get_children():
		if child.has_method("apply_theme"):
			child.parsed = true
			child.es_font_path = es_font_path
			child.es_font_size = es_font_size
			child.es_color = es_text_color
			child.es_force_uppercase = true
			child.apply_theme()
		else:
			child.max_width = max(size.y, es_font_size)

	position = es_position
	
	size = Vector2(PropertyWrapper.screen_width, 1.25 * es_font_size)
	es_pos_origin.x *= size.x
	es_pos_origin.y *= size.y
	position -= es_pos_origin
