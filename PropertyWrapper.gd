extends Object

var screen_width = 1024
var screen_height = 576

func parse_normalized_pair(Wrapper, data: String, to_absolute: bool = true) -> Vector2:
	data = parse_string(Wrapper, data)
	var splits = data.split(" ")
	var x = float(splits[0])
	var y = float(splits[1])
	if to_absolute:
		x *= screen_width
		y *= screen_height

	return Vector2(x, y)

func parse_normalized_rect(Wrapper, data: String) -> Rect2:
	data = parse_string(Wrapper, data)
	var splits = data.split(" ")
	var top = float(splits[0]) * screen_height
	var left = float(splits[1]) * screen_width
	var bottom = float(splits[2]) * screen_height
	var right = float(splits[3]) * screen_width
	
	var x = screen_width - left
	var y = screen_height - top
	var w = screen_width - x - right
	var h = screen_height - y - bottom
	return Rect2(x, y, w, h)

func parse_path(Wrapper, data: String, path: String) -> String:
	data = parse_string(Wrapper, data)
	return Wrapper.expand_file_path(data, path.get_base_dir())

func parse_bool(Wrapper, data: String) -> bool:
	data = parse_string(Wrapper, data)
	match data:
		"true", "1":
			return true
		"false", "0":
			return false
		_:
			return false

func parse_color(Wrapper, data: String) -> Color:
	data = parse_string(Wrapper, data)
	if data.length() == 8:
		var color_str = data.substr(6) +  data.substr(0, 6)
		return Color(color_str)
	else:
		return Color(data)

func parse_float(Wrapper, data: String) -> float:
	data = parse_string(Wrapper, data)
	return float(data)

func parse_string(Wrapper, data: String) -> String:
	if data is String:
		return JSONUtils.format_string_with_substitutes(data, Wrapper.xml_variables, "${", "}", true)
	else:
		return str(data)
