extends TextureRect

var n_mix_image : Node = null

var PropertyWrapper = load("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
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


func parse_theme_xml(Wrapper, data: Dictionary, root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size", "maxSize":
				size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"rotation":
				rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"rotationOrigin":
				rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"path", "default":
				tex_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
				var img = Image.new()
				if not img.load(tex_path):
					tex = ImageTexture.new()
					tex.create_from_image(img, 3)
			"tile":
				tile = PropertyWrapper.parse_bool(Wrapper, data[key])
			"color":
				color = PropertyWrapper.parse_color(Wrapper, data[key])
			"visible":
				is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	rect_position = position
	if tex:
		texture = tex
	if texture:
		var tex_size = texture.get_size()
		if size == null:
			size = tex_size
		elif size.x == 0 and size.y == 0:
			size = Vector2(0.001, 0.001)
		elif size.x == 0:
			size.x = tex_size.x * size.y / tex_size.y
		elif size.y == 0:
			size.y = tex_size.y * size.x / tex_size.x
	rect_size = size
	pos_origin.x *= size.x
	pos_origin.y *= size.y
	rect_position -= pos_origin
	rot_pivot.x *= size.x
	rot_pivot.y *= size.y
	rect_pivot_offset = rot_pivot
	rect_rotation = rotation
	if tile:
		stretch_mode = TextureRect.STRETCH_TILE
	self_modulate = color
	visible = is_visible
