extends Node

var cached_objects := {}
var cached_z_indexes := {}

onready var n_background := $"Children/0/background"
onready var n_gamelist := $"Children/20/gamelist"
onready var n_logoText := $"Children/50/logoText"
onready var n_logo := $"Children/50/logo"
onready var n_helpsystem := $HelpSystem

onready var n_default_objects := [
	n_background,
	n_gamelist,
	n_logoText,
	n_logo,
	n_helpsystem
]

func _ready():
	for child in $Children.get_children():
		cached_z_indexes[child.name] = child

func parse_theme_xml(Wrapper, path: String) -> void:
	path = Wrapper.ensure_path(path)
	if Wrapper.xml_filemap.has(path):
		var data = Wrapper.xml_filemap[path]
		if data.has("include"):
			var includes : Array = Wrapper.expand_include(data["include"], path.get_base_dir())
			for include in includes:
				parse_theme_xml(Wrapper, include)
		if Wrapper.has(data, "view"):
			var views = Wrapper.find_view(data, "basic")
			for view in views:
				parse_theme_xml_view(Wrapper, view, path)

func apply_theme():
	handle_default_objects()
	
	for obj in cached_objects.values():
		handle_z_index(obj)
		obj.apply_theme()
	for obj in n_default_objects:
		obj.apply_theme()
	cached_objects.clear()

func handle_default_objects():
	if n_logo.parsed:
		n_logoText.visible = false

# Godot is annoying when it comes to Z-indexing for UI. So we gotta do some tricks here.
func handle_z_index(obj):
	var z_index = obj.z_index
	if not cached_z_indexes.has(str(z_index)):
		var idx = get_idx_for_z_index(z_index)
		var node = create_z_index_node()
		node.name = str(z_index)
		$Children.add_child(node, true)
		$Children.move_child(node, idx)
		cached_z_indexes[str(z_index)] = node

	cached_z_indexes[str(z_index)].add_child(obj)

func create_z_index_node():
	var node := Control.new()
	node.anchor_right = 1
	node.anchor_bottom = 1
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func get_idx_for_z_index(z_index: int) -> int:
	var idx = 0
	for child in $Children.get_children():
		if int(child.name) > z_index:
			return idx
		idx += 1
	return idx

func parse_theme_xml_view(Wrapper, data: Dictionary, path: String) -> void:
	for key in data:
		match key:
			"helpsystem":
				parse_theme_xml_helpsystem(Wrapper, data[key] if data[key] is Array else [data[key]], path)
			"image":
				parse_theme_xml_image(Wrapper, data[key] if data[key] is Array else [data[key]], path)
			"text":
				parse_theme_xml_text(Wrapper, data[key] if data[key] is Array else [data[key]], path)
			"textlist":
				parse_theme_xml_textlist(Wrapper, data[key] if data[key] is Array else [data[key]], path)
			_:
				pass

func parse_theme_xml_helpsystem(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "help":
				n_helpsystem.parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_image(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name in ["md_image", "md_marquee"]:
				continue
			if name == "background":
				n_background.parse_theme_xml(Wrapper, data, path)
			elif name == "logo":
				n_logo.parse_theme_xml(Wrapper, data, path)
			else:
				if not cached_objects.has(name):
					cached_objects[name] = preload("res://objects/image/Image.tscn").instance()
					cached_objects[name].name = name
				cached_objects[name].parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_text(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name in ["gamelistInfo", "md_lbl_rating", "md_lbl_releasedate",
				"md_lbl_developer", "md_lbl_publisher", "md_lbl_genre",
				"md_lbl_players", "md_lbl_lastplayed", "md_lbl_playcount",
				"md_developer", "md_publisher", "md_genre", "md_players",
				"md_playcount", "md_description", "md_name"]:
				continue
			if name == "logoText":
				n_logoText.parse_theme_xml(Wrapper, data, path)
			else:
				if not cached_objects.has(name):
					cached_objects[name] = preload("res://objects/text/Text.tscn").instance()
					cached_objects[name].name = name
				cached_objects[name].parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_textlist(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "gamelist":
				n_gamelist.parse_theme_xml(Wrapper, data, path)

func set_system(system: RetroHubSystemData) -> void:
	n_logoText.text = system.fullname

func set_games(games: Array) -> void:
	n_gamelist.games = games

func app_returned(data: RetroHubGameData) -> void:
	n_gamelist.app_returned(data)

func reset() -> void:
	n_gamelist.reset()

func on_show():
	n_gamelist.get_focus()

func on_hide():
	pass

func clear_game_media_cache():
	pass
