extends Control

var tex_mult : int
var rating : float setget set_rating

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
export var pos_origin := Vector2(0, 0)
var rotation := 0
var rot_pivot := Vector2(0, 0)
var filled_path := ""
var unfilled_path := ""
var color := Color(1, 1, 1, 1)
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
			"filledPath":
				filled_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"unfilledPath":
				unfilled_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
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
	if size.y > 0:
		rect_size = Vector2(floor(size.y) * 5, floor(size.y))
	elif size.x > 0:
		rect_size = Vector2(floor(size.x) * 5, floor(size.x))
	pos_origin.x *= rect_size.x
	pos_origin.y *= rect_size.y
	rect_position -= pos_origin
	rot_pivot.x *= rect_size.x
	rot_pivot.y *= rect_size.y
	rect_pivot_offset = rot_pivot
	rect_rotation = rotation
	if not filled_path.empty() and not unfilled_path.empty():
		var img = Image.new()
		for data in [[filled_path, $Tex_Filled], [unfilled_path, $Tex_Unfilled]]:
			img.load(data[0])
			var tex = ImageTexture.new()
			tex.create_from_image(img, 3)
			tex.set_size_override(Vector2(rect_size.y, rect_size.y))
			data[1].texture = tex
		tex_mult = rect_size.x
	self_modulate = color
	visible = is_visible


func set_rating(_rating: float) -> void:
	rating = _rating
	$Tex_Filled.rect_size.x = tex_mult * clamp(stepify(rating, 0.1), 0.0, 1.0)

func _ready():
	tex_mult = $Tex_Filled.rect_size.x
	$Tex_Filled.rect_size.x = 0
