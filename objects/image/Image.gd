extends TextureRect

var n_mix_image : Node = null

var PropertyWrapper = load("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0)
@export var size_set := false
@export var es_size := Vector2 (0, 0)
@export var es_max_size := Vector2.ZERO
@export var es_pos_origin := Vector2(0, 0)
var es_rotation := 0.0
var es_rot_pivot := Vector2(0, 0)
var es_tex_path : String = ""
var es_tex : ImageTexture = null
var es_tile := false
var es_color := Color(1, 1, 1, 1)
var es_is_visible := true
@export var es_z_index := 10

func set_media(data: RetroHubGameMediaData):
	if data:
		if data.screenshot and data.box_render \
			and data.support_render and data.logo:
			self_modulate = Color(0, 0, 0, 0)
			if not n_mix_image:
				n_mix_image = preload("res://objects/image/MixImage.tscn").instantiate()
				add_child(n_mix_image)
			visible = true
			n_mix_image.visible = true
			n_mix_image.parse_media_data(data)
		else:
			self_modulate = es_color
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
				es_position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				es_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"maxSize":
				es_max_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				es_pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"rotation":
				es_rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"rotationOrigin":
				es_rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"path", "default":
				es_tex_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
				if not FileAccess.file_exists(es_tex_path):
					return
				var img = Image.load_from_file(es_tex_path)
				if img:
					es_tex = ImageTexture.create_from_image(img)
			"tile":
				es_tile = PropertyWrapper.parse_bool(Wrapper, data[key])
			"color":
				es_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"visible":
				es_is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))

func handle_max_size():
	if es_max_size != Vector2.ZERO:
		var tex_size : Vector2
		if get_child_count() > 0: # Miximage
			tex_size = es_max_size
		elif texture:
			tex_size = texture.get_size()
			if tex_size == Vector2.ZERO:
				tex_size = es_max_size
			else:
				# X > Y
				if tex_size.x > tex_size.y:
					tex_size.y = tex_size.y * es_max_size.x / tex_size.x
					tex_size.x = es_max_size.x
				# Y > X
				else:
					tex_size.x = tex_size.x * es_max_size.y / tex_size.y
					tex_size.y = es_max_size.y
		position = es_position
		size = tex_size
		var pos_origin_abs = es_pos_origin
		pos_origin_abs.x *= tex_size.x
		pos_origin_abs.y *= tex_size.y
		position -= pos_origin_abs
		es_rot_pivot.x *= tex_size.x
		es_rot_pivot.y *= tex_size.y
		pivot_offset = es_rot_pivot

func apply_theme():
	if not parsed:
		return

	position = es_position
	if es_tex:
		texture = es_tex
	if texture:
		var tex_size = texture.get_size()
		handle_max_size()
		if es_max_size == Vector2.ZERO:
			if es_size.x == 0 and es_size.y == 0:
				es_size = Vector2(0.001, 0.001)
			elif es_size.x == 0:
				es_size.x = tex_size.x * es_size.y / tex_size.y
			elif es_size.y == 0:
				es_size.y = tex_size.y * es_size.x / tex_size.x
	stretch_mode = TextureRect.STRETCH_SCALE
	if es_max_size == Vector2.ZERO: # Handled by handle_max_size already
		size = es_size
		var pos_origin_abs = es_pos_origin
		pos_origin_abs.x *= es_size.x
		pos_origin_abs.y *= es_size.y
		position -= pos_origin_abs
		es_rot_pivot.x *= es_size.x
		es_rot_pivot.y *= es_size.y
		pivot_offset = es_rot_pivot
	rotation = es_rotation
	if es_tile:
		stretch_mode = TextureRect.STRETCH_TILE
	self_modulate = es_color
	visible = es_is_visible
