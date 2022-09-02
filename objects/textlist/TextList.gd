extends ScrollContainer

signal game_entry_selected(data)

export(PackedScene) var game_entry_scene : PackedScene

var games := [] setget set_games

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0)
export var size_set := false
export var size := Vector2 (0, 0)
export var pos_origin := Vector2(0, 0)
var selector_color := Color(0, 0, 0, 1)
var selector_image_path := "res://assets/graphics/background.png"
var selector_image_tile := false
var selector_height := 40.5
var selector_offset_y := 0.0
var selected_color := Color(0, 0, 1, 1)
var primary_color := Color(0, 0, 1, 1)
var secondary_color := Color(0, 1, 0, 1)
var font_path := ""
var font_size := 27.0
export var alignment = Label.ALIGN_CENTER
var horizontal_margin := 0.0
var force_uppercase := false
var line_spacing := 1.5
export var z_index := 10

var style_focused := StyleBoxTexture.new()
var font : DynamicFont

func set_games(_games: Array) -> void:
	reset()
	games = _games
	for game in games:
		add_game(game)
	connect_neighbors()
	#get_focus()

func add_game(data: RetroHubGameData):
	var child := game_entry_scene.instance()
	$VBoxContainer.add_child(child)
	child.align = alignment
	child.height = selector_height
	child.style = style_focused
	child.font = font
	child.font_color = primary_color
	child.font_color_selected = selected_color
	child.game_data = data
	child.connect("selected", self, "_on_game_entry_selected")

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
		start.focus_neighbour_top = NodePath("../" + end.name)
		end.focus_neighbour_bottom = NodePath("../" + start.name)

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
				position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"selectorColor":
				selector_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"selectorImagePath":
				selector_image_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"selectorImageTile":
				selector_image_tile = PropertyWrapper.parse_bool(Wrapper, data[key])
			"selectorHeight":
				selector_height = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"selectorOffsetY":
				selector_offset_y = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"selectedColor":
				selected_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"primaryColor":
				primary_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"secondaryColor":
				secondary_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"fontPath":
				font_path = PropertyWrapper.parse_path(Wrapper, data[key], root_path)
			"fontSize":
				font_size = PropertyWrapper.parse_float(Wrapper, data[key]) * PropertyWrapper.screen_height
			"alignment":
				alignment = PropertyWrapper.parse_string(Wrapper, data[key])
			"horizontalMargin":
				horizontal_margin = PropertyWrapper.parse_float(Wrapper, data[key])
			"forceUppercase":
				force_uppercase = PropertyWrapper.parse_bool(Wrapper, data[key])
			"lineSpacing":
				line_spacing = PropertyWrapper.parse_float(Wrapper, data[key])
			"zIndex":
				z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	rect_position = position
	match alignment:
		"left":
			alignment = Label.ALIGN_LEFT
		"center":
			alignment = Label.ALIGN_CENTER
		"right":
			alignment = Label.ALIGN_RIGHT
	rect_size = size
	pos_origin.x *= rect_size.x
	pos_origin.y *= rect_size.y
	rect_position -= pos_origin
	create_game_entry_style()

func create_game_entry_style():
	var img = Image.new()
	img.load(selector_image_path)
	var tex = ImageTexture.new()
	tex.create_from_image(img, 3)
	style_focused.texture = tex
	if selector_image_tile:
		style_focused.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style_focused.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	style_focused.modulate_color = selector_color
	# TODO: selector_height & selector_offset_y

	if not font_path.empty():
		font = DynamicFont.new()
		font.font_data = load(font_path)
		# TODO: Figure out line spacing as there's no 1:1 translation for Godot
		var spacing = (line_spacing-1.6) * font_size / 2
		#font.extra_spacing_top = spacing / 2
		#font.extra_spacing_bottom = spacing / 2
		font.size = font_size
		# We have to wait a frame, I suppose font_data sets something in the meantime
		# If we don't wait, it requests stupidly large sizes
		#yield(get_tree(), "idle_frame")
