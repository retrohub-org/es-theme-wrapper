extends ScrollContainer

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
export var pos_origin := Vector2(0, 0)
var rotation := 0
var rot_pivot := Vector2(0, 0)
export var txt := ""
export var color := Color(1, 1, 1, 1)
var background_color := Color(0, 0, 0, 0)
var font_path := ""
var font_size := 27
export var alignment := "left"
var force_uppercase := false
var line_spacing := 1.5
var is_visible := true
export var z_index := 10

var text : String setget set_text, get_text

var clip_pre_delay : float
var clip_speed : float = 0.0
var clip_post_delay : float

var _clip_pre_delay_timer : Timer = null
var _clip_post_delay_timer : Timer = null
var _clip_val : float
var _is_clipping : bool
var _clip_is_scrolling : bool
var _gamelist_visible : bool

func set_text(_text: String):
	$Label.text = _text
	set_is_clipping()

func get_text() -> String:
	return $Label.text

func set_is_clipping():
	_is_clipping = $Label.rect_size.x > rect_size.x or $Label.rect_size.y > rect_size.y
	if _is_clipping and clip_speed > 0:
		if not _clip_pre_delay_timer:
			_clip_pre_delay_timer = Timer.new()
			_clip_post_delay_timer = Timer.new()
			_clip_pre_delay_timer.one_shot = true
			_clip_pre_delay_timer.autostart = false
			_clip_pre_delay_timer.wait_time = clip_pre_delay
			#warning-ignore:return_value_discarded
			_clip_pre_delay_timer.connect("timeout", self, "_on_clip_pre_delay_Timeout")

			_clip_post_delay_timer.one_shot = true
			_clip_post_delay_timer.autostart = false
			_clip_post_delay_timer.wait_time = clip_post_delay
			#warning-ignore:return_value_discarded
			_clip_post_delay_timer.connect("timeout", self, "_on_clip_post_delay_Timeout")
			
			add_child(_clip_pre_delay_timer)
			add_child(_clip_post_delay_timer)
		if _gamelist_visible:
			on_gamelist_hide()
			on_gamelist_show()

func _on_clip_pre_delay_Timeout():
	_clip_val = 0.0
	_clip_is_scrolling = true

func _on_clip_post_delay_Timeout():
	_clip_is_scrolling = false
	scroll_vertical = 0
	scroll_horizontal = 0
	_clip_val = 0.0
	_clip_pre_delay_timer.start()

func on_gamelist_show():
	_gamelist_visible = true
	if _is_clipping and clip_speed > 0 and _clip_pre_delay_timer:
		_clip_pre_delay_timer.start()

func on_gamelist_hide():
	_gamelist_visible = false
	if _is_clipping and clip_speed > 0 and _clip_pre_delay_timer:
		_clip_is_scrolling = false
		_clip_pre_delay_timer.stop()
		_clip_post_delay_timer.stop()
		scroll_horizontal = 0
		scroll_vertical = 0

func _process(delta):
	if _is_clipping:
		if _clip_is_scrolling and _clip_post_delay_timer.is_stopped():
			_clip_val += delta * clip_speed
			if get_v_scrollbar().is_visible_in_tree():
				var max_val = $Label.rect_size.y - rect_size.y
				scroll_vertical = int(_clip_val)
				if scroll_vertical >= int(max_val):
					_clip_post_delay_timer.start()
			elif get_h_scrollbar().is_visible_in_tree():
				var max_val = $Label.rect_size.x - rect_size.x
				scroll_horizontal = int(_clip_val)
				if scroll_horizontal >= int(max_val):
					_clip_post_delay_timer.start()

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
		$Label.add_font_override("font", dynamic_font)
		# We have to wait a frame, I suppose font_data sets something in the meantime
		# If we don't wait, it requests stupidly large sizes
	if txt.length():
		set_text(txt)
	match alignment:
		"left":
			$Label.align = Label.ALIGN_LEFT
		"center":
			$Label.align = Label.ALIGN_CENTER
			$Label.valign = Label.VALIGN_CENTER
		"right":
			$Label.align = Label.ALIGN_RIGHT
	$Label.uppercase = force_uppercase
	$Label/Background.color = background_color
	var text_size : Vector2 = $Label.get_minimum_size()
	if size.x == 0 and size.y == 0:
		$Label.autowrap = false
		rect_min_size = text_size
	else:
		$Label.autowrap = true
		if size.y == 0:
			rect_size.x = size.x
			rect_size.y = text_size.y
		else:
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
	$Label.add_color_override("font_color", color)
	visible = is_visible

