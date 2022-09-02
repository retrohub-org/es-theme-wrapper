extends Label

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
export var pos_origin := Vector2(0, 0)
var rotation := 0
var rot_pivot := Vector2(0, 0)
var txt := ""
var color := Color(1, 1, 1, 1)
var background_color := Color(0, 0, 0, 0)
var font_path := ""
var font_size := 27
var alignment := "left"
var force_uppercase := false
var line_spacing := 1.5
var is_visible := true
export var z_index := 10

func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"rotation":
				rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"rotationOrigin":
				rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"text":
				txt = PropertyWrapper.parse_string(Wrapper, data[key])
			"color":
				color = PropertyWrapper.parse_color(Wrapper, data[key])
			"backgroundColor":
				background_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"alignment":
				alignment = PropertyWrapper.parse_string(Wrapper, data[key])
			"forceUppercase":
				force_uppercase = PropertyWrapper.parse_bool(Wrapper, data[key])
			"lineSpacing":
				line_spacing = PropertyWrapper.parse_float(Wrapper, data[key])
			"visible":
				is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	rect_position = position
	if not font_path.empty():
		var dynamic_font := DynamicFont.new()
		dynamic_font.font_data = load(font_path)
		# TODO: Figure out line spacing as there's no 1:1 translation for Godot
		var spacing = (line_spacing-1.6) * font_size / 2
		dynamic_font.extra_spacing_top = spacing / 2
		dynamic_font.extra_spacing_bottom = spacing / 2
		dynamic_font.size = font_size
		#set("custom_fonts/font", dynamic_font)
		add_font_override("font", dynamic_font)
		# We have to wait a frame, I suppose font_data sets something in the meantime
		# If we don't wait, it requests stupidly large sizes
	if txt.length():
		text = txt
	match alignment:
		"left":
			align = Label.ALIGN_LEFT
		"center":
			align = Label.ALIGN_CENTER
			valign = Label.VALIGN_CENTER
		"right":
			align = Label.ALIGN_RIGHT
	uppercase = force_uppercase
	$Background.color = background_color
	if size.x == 0 and size.y == 0:
		autowrap = false
		rect_size = size
	else:
		autowrap = true
		if size.y == 0:
			rect_size.x = size.x
			rect_size.y = 0
		else:
			clip_text = true
			rect_size = size
			if size.y < font_size:
				rect_size.y = font_size
	pos_origin.x *= rect_size.x
	pos_origin.y *= rect_size.y
	rect_position -= pos_origin
	rot_pivot.x *= rect_size.x
	rot_pivot.y *= rect_size.y
	rect_pivot_offset = rot_pivot
	rect_rotation = rotation
	add_color_override("font_color", color)
	visible = is_visible
