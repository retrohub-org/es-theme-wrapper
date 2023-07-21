extends ScrollContainer

signal game_entry_selected(data)

@export var game_entry_scene: PackedScene

var games := []:
	set(value):
		reset()
		games = value
		for game in games:
			add_game(game)
		connect_neighbors()

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0)
@export var size_set := false
@export var es_size := Vector2 (0, 0)
@export var es_pos_origin := Vector2(0, 0)
var es_selector_color := Color(0, 0, 0, 1)
var es_selector_image_path := "res://assets/graphics/background.png"
var es_selector_image_tile := false
var es_selector_height := 40.5
var es_selector_offset_y := 0.0
var es_selected_color := Color(0, 0, 1, 1)
var es_primary_color := Color(0, 0, 1, 1)
var es_secondary_color := Color(0, 1, 0, 1)
var es_font_path := ""
var es_font_size := 27.0
@export var es_alignment = HORIZONTAL_ALIGNMENT_CENTER
var es_horizontal_margin := 0.0
var es_force_uppercase := false
var es_line_spacing := 1.5
@export var es_z_index := 10

var style_focused := StyleBoxTexture.new()
var font : FontFile

func add_game(data: RetroHubGameData):
	var child := game_entry_scene.instantiate()
	$VBoxContainer.add_child(child)
	child.alignment = es_alignment
	child.height = es_selector_height
	child.style = style_focused
	child.font = font
	child.font_size = es_font_size
	child.font_color = es_primary_color
	child.font_color_selected = es_selected_color
	child.game_data = data
	#warning-ignore:return_value_discarded
	child.selected.connect(_on_game_entry_selected)

func _on_game_entry_selected(game_data: RetroHubGameData):
	emit_signal("game_entry_selected", game_data)

func app_returned(data: RetroHubGameData) -> void:
	for child in $VBoxContainer.get_children():
		if child.game_data == data:
			child.grab_focus()
			return

func reset() -> void:
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		child.queue_free()

func connect_neighbors() -> void:
	if $VBoxContainer.get_child_count() > 1:
		var start : Control = $VBoxContainer.get_child(0)
		var end : Control = $VBoxContainer.get_child($VBoxContainer.get_child_count() - 1)
		start.focus_neighbor_top = NodePath("../" + end.name)
		end.focus_neighbor_bottom = NodePath("../" + start.name)

func get_focus():
	if $VBoxContainer.get_child_count() > 0:
		var child = $VBoxContainer.get_child(0)
		child.grab_focus()
		scroll_vertical = 0

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
			"selectorColor":
				es_selector_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"selectorImagePath":
				es_selector_image_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"selectorImageTile":
				es_selector_image_tile = PropertyWrapper.parse_bool(Wrapper, data[key])
			"selectorHeight":
				es_selector_height = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"selectorOffsetY":
				es_selector_offset_y = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"selectedColor":
				es_selected_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"primaryColor":
				es_primary_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"secondaryColor":
				es_secondary_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				es_font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				es_font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"alignment":
				es_alignment = PropertyWrapper.parse_string(Wrapper, data[key])
			"horizontalMargin":
				es_horizontal_margin = PropertyWrapper.parse_float(Wrapper, data[key])
			"forceUppercase":
				es_force_uppercase = PropertyWrapper.parse_bool(Wrapper, data[key])
			"lineSpacing":
				es_line_spacing = PropertyWrapper.parse_float(Wrapper, data[key])
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	position = es_position
	match es_alignment:
		"left":
			es_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"center":
			es_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"right":
			es_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	size = es_size
	es_pos_origin.x *= size.x
	es_pos_origin.y *= size.y
	position -= es_pos_origin
	create_game_entry_style()

func create_game_entry_style():
	if es_selector_image_path.begins_with("res://"):
		style_focused.texture = load(es_selector_image_path)
	else:
		var img = Image.load_from_file(es_selector_image_path)
		var tex = ImageTexture.create_from_image(img)
		style_focused.texture = tex
	if es_selector_image_tile:
		style_focused.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style_focused.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	style_focused.modulate_color = es_selector_color
	# TODO: es_selector_height & es_selector_offset_y

	if not es_font_path.is_empty():
		font = FontFile.new()
		font.load_dynamic_font(es_font_path)
