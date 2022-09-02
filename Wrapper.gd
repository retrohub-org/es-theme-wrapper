extends Node

var xml2json = load("res://XML2JSON.gd").new()

# Holds mapping between files and content; this is because themes cross-reference files
var xml_filemap := {}
var xml_variables := {}
var theme_config := {}

# Used if any system name has diverged from ES
func convert_system_name(system_name: String):
	return system_name

func load_es_theme_file(path: String):
	# Load generic theme.xml, used when no themes are found
	var dict : Dictionary = xml2json.parse(path)
	var root_path = path.get_base_dir()
	if not dict.empty():
		xml_filemap[path] = dict["theme"]
		map_xml_content(xml_filemap[path], root_path)
		"""var file := File.new()
		var dir := Directory.new()
		dir.make_dir_recursive("/tmp/rh/" + system_name)
		var err = file.open("/tmp/rh/" + system_name + "/" + path.get_basename().get_file() + ".json", File.WRITE)
		file.store_string(JSON.print(dict, "  "))
		file.close()"""

func map_xml_content(dict: Dictionary, root_path: String):
	for key in dict:
		if key == "include":
			var values = dict[key] if dict[key] is Array else [dict[key]]
			for val in values:
				var path = expand_file_path(val, root_path)
				if not xml_filemap.has(path):
					load_es_theme_file(path)
		elif key == "variables":
			var values = dict[key] if dict[key] is Array else [dict[key]]
			for d in values:
				for k in d:
					xml_variables[k] = d[k]
		elif dict[key] is Dictionary:
			map_xml_content(dict[key], root_path)
		elif dict[key] is Array:
			for val in dict[key]:
				if val is Dictionary:
					map_xml_content(val, root_path)

func expand_file_path(path: String, root_path: String):
	if path[0] == '.':
		path = root_path + path.substr(1)
	elif path[0] == '~':
		path = FileUtils.get_home_dir() + path.substr(1)
	var back_idx = path.find("..")
	while back_idx != -1:
		var slash = path.substr(0, back_idx-1).find_last("/")
		assert(slash != -1)
		path = path.substr(0, slash) + path.substr(back_idx+2)
		back_idx = path.find("..")
	return path

func get_xml_config_for_system(path: String):
	return xml_filemap[path]

func set_system_variables(data: RetroHubSystemData):
	xml_variables["system.name"] = data.name
	xml_variables["system.fullName"] = data.fullname
	xml_variables["system.theme"] = data.name

func expand_include(data, root_path: String) -> Array:
	var paths = data if data is Array else [data]
	var abs_paths := []
	for path in paths:
		abs_paths.push_back(expand_file_path(path, root_path))
	return abs_paths

func has(data, name: String) -> bool:
	for key in data:
		if key == "feature" and supports_feature(data["feature"]):
			return has(data[key], name)
		elif key == name:
			return true
	return false

func find_view(data, name: String) -> Array:
	var views := []
	for key in data:
		if key == "feature" and supports_feature(data["feature"]):
			var sub_views = find_view(data[key], name)
			for sub_view in sub_views:
				views.push_back(sub_view)
		elif key == "view":
			for view in data[key] if data[key] is Array else [data[key]]:
				if is_attribute_present(view, name):
					views.push_back(view)
	return views

func supports_feature(data: Dictionary) -> bool:
	return data.has("#attributes") and data["#attributes"].has("supported") and \
		data["#attributes"]["supported"] in [
			#"navigationsounds", # TODO: Implement
			"video",
			"carousel",
			"z-index",
			"visible"
		]

func is_attribute_present(node: Dictionary, key: String):
	if not node.has("#attributes") or not node["#attributes"].has("name"):
		return false
	return parse_name_string(node["#attributes"]["name"], key)

func get_attributes(node: Dictionary) -> Array:
	if not node.has("#attributes") or not node["#attributes"].has("name"):
		return []
	var names = node["#attributes"]["name"]
	names = names.replace("\t", " ").replace("\r", " ").replace("\n", " ").replace(",", " ")
	return names.split(" ", false)

func is_extra(node: Dictionary):
	return node.has("#attributes") and node["#attributes"].has("extra") and node["#attributes"]["extra"] == "true"

func parse_name_string(keys: String, key: String):
	keys = keys.replace("\t", " ").replace("\r", " ").replace("\n", " ").replace(",", " ")
	for sub_key in keys.split(" ", false):
		if sub_key == key:
			return true
	return false

func ensure_path(path: String):
	if xml_filemap.has(path):
		return path
	return xml_filemap.keys()[0]
