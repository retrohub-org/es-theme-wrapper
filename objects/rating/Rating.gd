extends Control

var tex_mult : int
var rating : float: set = set_rating

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0)
@export var size_set := false
@export var es_size := Vector2 (0, 0)
@export var es_pos_origin := Vector2(0, 0)
var es_rotation := 0
var es_rot_pivot := Vector2(0, 0)
var es_filled_path := ""
var es_unfilled_path := ""
var es_color := Color(1, 1, 1, 1)
var es_is_visible := true
@export var es_z_index := 10

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
			"filledPath":
				es_filled_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"unfilledPath":
				es_unfilled_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"color":
				es_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"visible":
				es_is_visible = PropertyWrapper.parse_bool(Wrapper, data[key])
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	position = es_position
	if es_size.y > 0:
		size = Vector2(floor(es_size.y) * 5, floor(es_size.y))
	elif es_size.x > 0:
		size = Vector2(floor(es_size.x) * 5, floor(es_size.x))
	es_pos_origin.x *= es_size.x
	es_pos_origin.y *= es_size.y
	position -= es_pos_origin
	es_rot_pivot.x *= es_size.x
	es_rot_pivot.y *= es_size.y
	pivot_offset = es_rot_pivot
	rotation = es_rotation
	if not es_filled_path.is_empty() and not es_unfilled_path.is_empty():
		for data in [[es_filled_path, $Tex_Filled], [es_unfilled_path, $Tex_Unfilled]]:
			var img := Image.load_from_file(data[0])
			var tex := ImageTexture.create_from_image(img)
			tex.set_size_override(Vector2i(es_size.y, es_size.y))
			data[1].texture = tex
		tex_mult = int(es_size.x)
	self_modulate = es_color
	visible = es_is_visible


func set_rating(_rating: float) -> void:
	rating = _rating
	$Tex_Filled.size.x = tex_mult * clamp(snapped(rating, 0.1), 0.0, 1.0)

func _ready():
	tex_mult = $Tex_Filled.size.x
	$Tex_Filled.size.x = 0
