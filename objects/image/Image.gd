extends TextureRect

var n_mix_image : Node = null

var PropertyWrapper = load("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
export var max_size := Vector2.ZERO
export var pos_origin := Vector2(0, 0)
var rotation := 0
var rot_pivot := Vector2(0, 0)
var tex_path : String = ""
var tex : ImageTexture = null
var tile := false
var color := Color(1, 1, 1, 1)
var is_visible := true
export var z_index := 10

func set_media(data: RetroHubGameMediaData):
	if data:
		if data.screenshot and data.box_render \
			and data.support_render and data.logo:
			self_modulate = Color(0, 0, 0, 0)
			if not n_mix_image:
				n_mix_image = preload("res://objects/image/MixImage.tscn").instance()
				add_child(n_mix_image)
			visible = true
			n_mix_image.visible = true
			n_mix_image.parse_media_data(data)
		else:
			self_modulate = color
			visible = true
			if n_mix_image:
				n_mix_image.visible = false
			if data.screenshot:
				texture = data.screenshot
			elif data.title_screen:
				texture = data.title_screen
			else:
				visible = false
	else:
		visible = false
		texture = null
		if n_mix_image:
			n_mix_image.parse_media_data(null)
	handle_max_size()


func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"maxSize":
				max_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"rotation":
				rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"rotationOrigin":
				rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"path", "default":
				tex_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
				if not Directory.new().file_exists(tex_path):
					return
				var img = Image.new()
				if not img.load(tex_path):
					tex = ImageTexture.new()
					tex.create_from_image(img, 9)
			"tile":
				tile = PropertyWrapper.parse_bool(Wrapper, data[key])
			"color":
				color = PropertyWrapper.parse_color(Wrapper, data[key])
			"visible":
				is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))

func handle_max_size():
	if max_size != Vector2.ZERO:
		var tex_size : Vector2
		if get_child_count() > 0: # Miximage
			tex_size = max_size
		else:
			tex_size = texture.get_size()
			if tex_size == Vector2.ZERO:
				tex_size = max_size
			else:
				# X > Y
				if tex_size.x > tex_size.y:
					tex_size.y = tex_size.y * max_size.x / tex_size.x
					tex_size.x = max_size.x
				# Y > X
				else:
					tex_size.x = tex_size.x * max_size.y / tex_size.y
					tex_size.y = max_size.y
		rect_position = position
		rect_size = tex_size
		var pos_origin_abs = pos_origin
		pos_origin_abs.x *= tex_size.x
		pos_origin_abs.y *= tex_size.y
		rect_position -= pos_origin_abs
		rot_pivot.x *= tex_size.x
		rot_pivot.y *= tex_size.y
		rect_pivot_offset = rot_pivot

func apply_theme():
	if not parsed:
		return

	rect_position = position
	if tex:
		texture = tex
	if texture:
		var tex_size = texture.get_size()
		handle_max_size()
		if max_size == Vector2.ZERO:
			if size.x == 0 and size.y == 0:
				size = Vector2(0.001, 0.001)
			elif size.x == 0:
				size.x = tex_size.x * size.y / tex_size.y
			elif size.y == 0:
				size.y = tex_size.y * size.x / tex_size.x
	stretch_mode = TextureRect.STRETCH_SCALE
	if max_size == Vector2.ZERO: # Handled by handle_max_size already
		rect_size = size
		var pos_origin_abs = pos_origin
		pos_origin_abs.x *= size.x
		pos_origin_abs.y *= size.y
		rect_position -= pos_origin_abs
		rot_pivot.x *= size.x
		rot_pivot.y *= size.y
		rect_pivot_offset = rot_pivot
	rect_rotation = rotation
	if tile:
		stretch_mode = TextureRect.STRETCH_TILE
	self_modulate = color
	visible = is_visible
