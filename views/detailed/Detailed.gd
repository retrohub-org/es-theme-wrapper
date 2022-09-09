extends Node

export(int, 1, 64) var media_cached_entries := 8

var game_media_cache := {}

var cached_objects := {}
var cached_z_indexes := {}
var game_data : RetroHubGameData

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

onready var n_md_lbl_rating := $"Children/40/md_lbl_rating"
onready var n_md_lbl_releasedate := $"Children/40/md_lbl_releasedate"
onready var n_md_lbl_developer := $"Children/40/md_lbl_developer"
onready var n_md_lbl_publisher := $"Children/40/md_lbl_publisher"
onready var n_md_lbl_genre := $"Children/40/md_lbl_genre"
onready var n_md_lbl_players := $"Children/40/md_lbl_players"
onready var n_md_lbl_lastplayed := $"Children/40/md_lbl_lastplayed"
onready var n_md_lbl_playcount := $"Children/40/md_lbl_playcount"
onready var n_md_image := $"Children/40/md_image"
onready var n_md_rating := $"Children/40/md_rating"
onready var n_md_releasedate := $"Children/40/md_releasedate"
onready var n_md_developer := $"Children/40/md_developer"
onready var n_md_publisher := $"Children/40/md_publisher"
onready var n_md_genre := $"Children/40/md_genre"
onready var n_md_players := $"Children/40/md_players"
onready var n_md_lastplayed := $"Children/40/md_lastplayed"
onready var n_md_playcount := $"Children/40/md_playcount"
onready var n_md_description := $"Children/40/md_description"

onready var n_md_default_objects := [
	n_md_lbl_rating,
	n_md_lbl_releasedate,
	n_md_lbl_developer,
	n_md_lbl_publisher,
	n_md_lbl_genre,
	n_md_lbl_players,
	n_md_lbl_lastplayed,
	n_md_lbl_playcount,
	n_md_image,
	n_md_rating,
	n_md_releasedate,
	n_md_developer,
	n_md_publisher,
	n_md_genre,
	n_md_players,
	n_md_lastplayed,
	n_md_playcount,
	n_md_description
]

func _ready():
	for child in $Children.get_children():
		cached_z_indexes[child.name] = child
	n_gamelist.connect("game_entry_selected", self, "_on_game_entry_selected")
	RetroHubConfig.connect("game_data_updated", self, "_on_game_data_updated")

func parse_theme_xml(Wrapper, path: String) -> void:
	path = Wrapper.ensure_path(path)
	var data = Wrapper.xml_filemap[path]
	if data.has("include"):
		var includes : Array = Wrapper.expand_include(data["include"], path.get_base_dir())
		for include in includes:
			parse_theme_xml(Wrapper, include)
	if Wrapper.has(data, "view"):
		var views = Wrapper.find_view(data, "detailed")
		for view in views:
			parse_theme_xml_view(Wrapper, view, path)

func apply_theme():
	handle_default_objects()
	
	for obj in cached_objects.values():
		handle_z_index(obj)
		obj.apply_theme()
	for obj in n_default_objects:
		obj.apply_theme()
	for obj in n_md_default_objects:
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
			"rating":
				parse_theme_xml_rating(Wrapper, data[key] if data[key] is Array else [data[key]], path)
			"datetime":
				parse_theme_xml_datetime(Wrapper, data[key] if data[key] is Array else [data[key]], path)
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
			if name == "md_image":
				n_md_image.parse_theme_xml(Wrapper, data, path)
			elif name in ["md_marquee"]:
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
			if name == "logoText":
				n_logoText.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_rating":
				n_md_lbl_rating.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_releasedate":
				n_md_lbl_releasedate.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_developer":
				n_md_lbl_developer.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_publisher":
				n_md_lbl_publisher.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_genre":
				n_md_lbl_genre.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_players":
				n_md_lbl_players.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_lastplayed":
				n_md_lbl_lastplayed.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lbl_playcount":
				n_md_lbl_playcount.parse_theme_xml(Wrapper, data, path)
			elif name == "md_developer":
				n_md_developer.parse_theme_xml(Wrapper, data, path)
			elif name == "md_publisher":
				n_md_publisher.parse_theme_xml(Wrapper, data, path)
			elif name == "md_genre":
				n_md_genre.parse_theme_xml(Wrapper, data, path)
			elif name == "md_players":
				n_md_players.parse_theme_xml(Wrapper, data, path)
			elif name == "md_playcount":
				n_md_playcount.parse_theme_xml(Wrapper, data, path)
			elif name == "md_description":
				n_md_description.parse_theme_xml(Wrapper, data, path)
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

func parse_theme_xml_rating(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "md_rating":
				n_md_rating.parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_datetime(Wrapper, datas: Array, path: String):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "md_releasedate":
				n_md_releasedate.parse_theme_xml(Wrapper, data, path)
			elif name == "md_lastplayed":
				n_md_lastplayed.parse_theme_xml(Wrapper, data, path)

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
	game_media_cache.clear()

func _on_game_entry_selected(_game_data: RetroHubGameData):
	if _game_data:
		game_data = _game_data
		n_md_developer.text = game_data.developer
		n_md_publisher.text = game_data.publisher
		n_md_genre.text = game_data.genres[0] if game_data.genres else ""
		n_md_playcount.text = str(game_data.play_count)
		n_md_description.text = game_data.description
		n_md_rating.rating = game_data.rating
		n_md_releasedate.date = game_data.release_date
		n_md_lastplayed.date = game_data.last_played
		
		if game_data.num_players:
			var splits = game_data.num_players.split("-")
			if splits[0] == splits[1]:
				n_md_players.text = splits[0]
			else:
				n_md_players.text = game_data.num_players
		
		if not game_media_cache.has(game_data):
			var media_data := RetroHubMedia.retrieve_media_data(game_data)
			game_media_cache[game_data] = media_data

		var media_data = game_media_cache[game_data]
		n_md_image.set_media(media_data)

		if game_media_cache.size() > media_cached_entries:
			var idx = randi() % game_media_cache.size()
			print("Evicting cache %d...", idx)
			var del_media_data = game_media_cache.keys()[idx]
			if media_data == del_media_data:
				del_media_data = game_media_cache.keys()[idx+1]
			game_media_cache.erase(del_media_data)
	else:
		n_md_developer.text = ""
		n_md_publisher.text = ""
		n_md_genre.text = ""
		n_md_playcount.text = ""
		n_md_description.text = ""
		n_md_rating.rating = 0
		n_md_releasedate.date = ""
		n_md_lastplayed.date = ""
		n_md_players.text = ""
		n_md_image.set_media(null)

func _on_game_data_updated(_game_data: RetroHubGameData):
	if game_data == _game_data:
		_on_game_entry_selected(game_data)
