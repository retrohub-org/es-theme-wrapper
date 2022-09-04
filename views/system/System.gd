extends Control

var cached_objects := {}
var cached_system_data := {}

onready var n_carousel := $Carousel
onready var n_helpsystem := $HelpSystem

onready var n_default_objects := [
	n_carousel,
	n_helpsystem
]

func grab_focus():
	n_carousel.grab_focus()

func _ready():
	RetroHub.connect("system_received", self, "add_system")
	RetroHub.connect("system_receive_end", self, "pack")

func parse_theme_xml(Wrapper, path: String, system_name: String) -> void:
	path = Wrapper.ensure_path(path)
	var data = Wrapper.xml_filemap[path]
	if data.has("include"):
		var includes : Array = Wrapper.expand_include(data["include"], path.get_base_dir())
		for include in includes:
			parse_theme_xml(Wrapper, include, system_name)
	if Wrapper.has(data, "view"):
		var views = Wrapper.find_view(data, "system")
		for view in views:
			parse_theme_xml_view(Wrapper, view, path, system_name)

func apply_theme():
	handle_default_objects()
	
	for obj in n_default_objects:
		obj.apply_theme()

func handle_default_objects():
	pass

func parse_theme_xml_view(Wrapper, data: Dictionary, path: String, system_name: String) -> void:
	if not cached_objects.has(system_name):
		cached_objects[system_name] = {}
	for key in data:
		match key:
			"helpsystem":
				parse_theme_xml_helpsystem(Wrapper, data[key] if data[key] is Array else [data[key]], path, cached_objects[system_name])
			"image":
				parse_theme_xml_image(Wrapper, data[key] if data[key] is Array else [data[key]], path, cached_objects[system_name])
			"text":
				parse_theme_xml_text(Wrapper, data[key] if data[key] is Array else [data[key]], path, cached_objects[system_name])
			"carousel":
				parse_theme_xml_carousel(Wrapper, data[key] if data[key] is Array else [data[key]], path, cached_objects[system_name])
			_:
				pass

func parse_theme_xml_helpsystem(Wrapper, datas: Array, path: String, root: Dictionary):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "help":
				n_helpsystem.parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_image(Wrapper, datas: Array, path: String, root: Dictionary):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "logo" or Wrapper.is_extra(data):
				if not root.has(name):
					var image = preload("res://objects/image/Image.tscn").instance()
					image.name = name
					image.max_size_set = true
					image.pos_origin = Vector2(0.5, 0.5)
					root[name] = image
				root[name].parse_theme_xml(Wrapper, data, path)

func parse_theme_xml_text(Wrapper, datas: Array, path: String, root: Dictionary):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "logoText" or name == "systemInfo" or Wrapper.is_extra(data):
				if not root.has(name):
					root[name] = preload("res://objects/text/Text.tscn").instance()
					root[name].name = name
				root[name].parse_theme_xml(Wrapper, data, path)


func parse_theme_xml_carousel(Wrapper, datas: Array, path: String, root: Dictionary):
	for data in datas:
		for name in Wrapper.get_attributes(data):
			if name == "systemcarousel":
				n_carousel.parse_theme_xml(Wrapper, data, path)

func add_system_data(data: RetroHubSystemData):
	cached_system_data[data.name] = data

func get_selected_system_data() -> RetroHubSystemData:
	return n_carousel.get_selected_system_data()

func pack():
	n_carousel.add_systems(cached_objects, cached_system_data)
