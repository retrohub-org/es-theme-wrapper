extends Label

var date : String: set = set_date

func set_date(_date : String) -> void:
	date = _date
	if date == null:
		text = "unknown"
	elif date == "null":
		text = "never"
	else:
		text = date

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0)
@export var size_set := false
@export var es_size := Vector2 (0, 0)
@export var es_pos_origin := Vector2(0, 0)
var es_rotation := 0
var es_rot_pivot := Vector2(0, 0)
var es_txt := ""
var es_color := Color(1, 1, 1, 1)
var es_background_color := Color(0, 0, 0, 0)
var es_font_path := ""
var es_font_size := 27
var es_alignment := "left"
var es_force_uppercase := false
var es_line_spacing := 1.5
var es_is_visible := true
@export var es_z_index := 10
var es_display_relative := true

func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				es_position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				es_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				es_pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"rotation":
				es_rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"rotationOrigin":
				es_rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"text":
				es_txt = PropertyWrapper.parse_string(Wrapper, data[key])
			"color":
				es_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"backgroundColor":
				es_background_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				es_font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				es_font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"es_alignment":
				es_alignment = PropertyWrapper.parse_string(Wrapper, data[key])
			"forceUppercase":
				es_force_uppercase = PropertyWrapper.parse_bool(Wrapper, data[key])
			"lineSpacing":
				es_line_spacing = PropertyWrapper.parse_float(Wrapper, data[key])
			"visible":
				es_is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
			"displayRelative":
				es_display_relative = PropertyWrapper.parse_bool(Wrapper, data[key])
			"format":
				pass # RetroHub properly handles regionalization efforts such as date format

func apply_theme():
	if not parsed:
		return

	position = es_position
	if not es_font_path.is_empty():
		var dynamic_font := FontVariation.new()
		dynamic_font.set_base_font(load(es_font_path))
		# TODO: Figure out line spacing as there's no 1:1 translation for Godot
		var spacing = (es_line_spacing-1.6) * es_font_size / 2
		dynamic_font.spacing_top = spacing / 2
		dynamic_font.spacing_bottom = spacing / 2
		#dynamic_font.font_size = es_font_size
		#set("custom_fonts/font", dynamic_font)
		add_theme_font_override("font", dynamic_font)
		# We have to wait a frame, I suppose font_data sets something in the meantime
		# If we don't wait, it requests stupidly large sizes
		await get_tree().process_frame
	match es_alignment:
		"left":
			horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"center":
			horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		"right":
			horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	uppercase = es_force_uppercase
	$Background.color = es_background_color
	if es_size.x == 0 and es_size.y == 0:
		autowrap_mode = TextServer.AUTOWRAP_OFF
		size = es_size
	else:
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if es_size.y == 0:
			es_size.x = es_size.x
			es_size.y = 0
		else:
			clip_text = true
			if es_size.y < es_font_size:
				es_size.y = es_font_size
			size = es_size
	es_pos_origin.x *= es_size.x
	es_pos_origin.y *= es_size.y
	position -= es_pos_origin
	es_rot_pivot.x *= es_size.x
	es_rot_pivot.y *= es_size.y
	pivot_offset = es_rot_pivot
	rotation = es_rotation
	add_theme_color_override("font_color", es_color)
	visible = es_is_visible
