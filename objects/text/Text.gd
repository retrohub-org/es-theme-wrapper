extends ScrollContainer

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0)
@export var size_set := false
@export var es_size := Vector2 (0, 0)
@export var es_pos_origin := Vector2(0, 0)
var es_rotation := 0.0
var es_rot_pivot := Vector2(0, 0)
@export var es_txt := ""
@export var es_color := Color(0, 0, 0, 1)
var es_background_color := Color(0, 0, 0, 0)
var es_font_path := ""
var es_font_size : float = 0.045 * min(PropertyWrapper.screen_width, PropertyWrapper.screen_height)
@export var es_alignment := "left"
var es_force_uppercase := false
var es_line_spacing := 1.5
var es_is_visible := true
@export var es_z_index := 10

var text : String:
	get:
		return $Label.text
	set(value):
		$Label.text = value
		set_is_clipping()

var clip_pre_delay : float
var clip_speed : float = 0.0
var clip_post_delay : float

var _clip_pre_delay_timer : Timer = null
var _clip_post_delay_timer : Timer = null
var _clip_val : float
var _is_clipping : bool
var _clip_is_scrolling : bool
var _gamelist_visible : bool

func set_is_clipping():
	_is_clipping = $Label.size.x > size.x or $Label.size.y > size.y
	if _is_clipping and clip_speed > 0:
		if not _clip_pre_delay_timer:
			_clip_pre_delay_timer = Timer.new()
			_clip_post_delay_timer = Timer.new()
			_clip_pre_delay_timer.one_shot = true
			_clip_pre_delay_timer.autostart = false
			_clip_pre_delay_timer.wait_time = clip_pre_delay
			#warning-ignore:return_value_discarded
			_clip_pre_delay_timer.timeout.connect(_on_clip_pre_delay_Timeout)

			_clip_post_delay_timer.one_shot = true
			_clip_post_delay_timer.autostart = false
			_clip_post_delay_timer.wait_time = clip_post_delay
			#warning-ignore:return_value_discarded
			_clip_post_delay_timer.timeout.connect(_on_clip_post_delay_Timeout)
			
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
			if get_v_scroll_bar().is_visible_in_tree():
				var max_val = $Label.size.y - size.y
				scroll_vertical = int(_clip_val)
				if scroll_vertical >= int(max_val):
					_clip_post_delay_timer.start()
			elif get_h_scroll_bar().is_visible_in_tree():
				var max_val = $Label.size.x - size.x
				scroll_horizontal = int(_clip_val)
				if scroll_horizontal >= int(max_val):
					_clip_post_delay_timer.start()

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
			"alignment":
				es_alignment = PropertyWrapper.parse_string(Wrapper, data[key])
			"forceUppercase":
				es_force_uppercase = PropertyWrapper.parse_bool(Wrapper, data[key])
			"lineSpacing":
				es_line_spacing = PropertyWrapper.parse_float(Wrapper, data[key])
			"visible":
				es_is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	position = es_position
	$Label.label_settings = LabelSettings.new()
	if not es_font_path.is_empty():
		var f := FontFile.new()
		f.load_dynamic_font(es_font_path)
		$Label.label_settings.font = f
	$Label.label_settings.line_spacing = es_line_spacing
	$Label.label_settings.font_size = es_font_size
	$Label.label_settings.font_color = es_color
	if es_txt.length():
		text = (es_txt)
	match es_alignment:
		"left":
			$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"center":
			$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			$Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		"right":
			$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	$Label.uppercase = es_force_uppercase
	$Label/Background.color = es_background_color
	var text_size : Vector2 = $Label.get_minimum_size()
	if es_size.x == 0 and es_size.y == 0:
		$Label.autowrap_mode = TextServer.AUTOWRAP_OFF
		custom_minimum_size = text_size
	else:
		$Label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if es_size.y == 0:
			size.x = es_size.x
			size.y = text_size.y
		else:
			size = es_size
			if es_size.y < es_font_size:
				size.y = es_font_size
	es_pos_origin.x *= size.x
	es_pos_origin.y *= size.y
	position -= es_pos_origin
	es_rot_pivot.x *= size.x
	es_rot_pivot.y *= size.y
	pivot_offset = es_rot_pivot
	rotation = es_rotation
	visible = es_is_visible

