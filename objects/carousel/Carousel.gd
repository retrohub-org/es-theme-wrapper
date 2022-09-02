extends Control

onready var n_logo_bar := $Pivot/ColorBar
onready var n_logo_children := $Pivot/Children
onready var n_extra_children := $Children
var system_count : int
var _head_idx
var _curr_idx
var _tail_idx
var move_stride : Vector2

var systems := []

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var position := Vector2(0, 0.38375 * 600)
export var size_set := false
export var size := Vector2 (1 * 1024, 0.2325 * 600)
export var pos_origin := Vector2(0, 0)
var type := "horizontal"
var color := Color("d8ffffff")
var logo_size := Vector2(0.25 * 1024, 0.155 * 600)
var logo_scale := 1.2
var logo_rotation := 7.5
var logo_rot_pivot := Vector2(-5 * 1024, 0.5 * 600)
var logo_align := "center"
var max_logo_count := 3
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
			"type":
				type = PropertyWrapper.parse_string(Wrapper, data[key])
			"color":
				color = PropertyWrapper.parse_color(Wrapper, data[key])
			"logoSize":
				logo_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"logoScale":
				logo_scale = PropertyWrapper.parse_float(Wrapper, data[key])
			"logoRotation":
				logo_rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"logoRotationOrigin":
				logo_rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"logoAlignment":
				logo_align = PropertyWrapper.parse_string(Wrapper, data[key])
			"maxLogoCount":
				max_logo_count = int(ceil(PropertyWrapper.parse_float(Wrapper, data[key])))
			"zIndex":
				z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	$Pivot.rect_position = position
	$Pivot.rect_size = size
	pos_origin.x *= rect_size.x
	pos_origin.y *= rect_size.y
	$Pivot.rect_position -= pos_origin
	n_logo_bar.color = color

func _gui_input(ev):
	if system_count > 1:
		if ev.is_action_pressed("ui_right", true):
			get_tree().set_input_as_handled()
			move_ui(1)
		if ev.is_action_pressed("ui_left", true):
			get_tree().set_input_as_handled()
			move_ui(-1)

func pack():
	ensure_min_child_count()
	system_count = n_logo_children.get_child_count()
	if system_count > 1:
		position_children()
	grab_focus()

func ensure_min_child_count():
	var child_count = n_logo_children.get_child_count()
	if child_count > 1 && child_count < 5:
		# Spawn duplicate system entries to properly create scrolling effect
		var remaining = 6 - child_count
		while remaining > 0:
			for i in child_count:
				n_logo_children.add_child(duplicate_entry(i % child_count))
			remaining -= child_count

func duplicate_entry(idx: int):
	var orig = n_logo_children.get_child(idx)
	var child = orig.duplicate()
	child.system_data = orig.system_data
	return child

func get_abs_idx(idx: int) -> int:
	if idx >= 0:
		return idx % system_count
	else:
		return (system_count-1) - ((-idx-1) % system_count)

func get_extra_for_idx(idx: int) -> Node:
	return n_extra_children.get_child(get_abs_idx(idx) % systems.size())

func position_children():
	var bar_width = $Pivot/ColorBar.rect_size.x / 1024
	move_stride = Vector2(((1024 - (logo_size.x * max_logo_count)) / (max_logo_count)) + logo_size.x, 0);
	move_stride.x *= bar_width
	for rel_idx in range(-2, system_count - 2):
		var idx = get_abs_idx(rel_idx)
		var pos = Vector2((1024 * bar_width / 2) + move_stride.x * (rel_idx), $Pivot/ColorBar.rect_size.y / 2)
		var node = n_logo_children.get_child(idx)
		node.set_pos(pos)
		node.center_nodes()
		node.set_selected(rel_idx == 0)
		if rel_idx == 0:
			_head_idx = get_abs_idx(-2)
			_curr_idx = idx
			_tail_idx = system_count - 3
			var extra = get_extra_for_idx(idx)
			extra.should_hide = false
			extra.visible = true

func add_systems(cached_objects: Dictionary, cached_system_data: Dictionary):
	for key in cached_objects:
		var nodes : Dictionary = cached_objects[key]
		var system_data : RetroHubSystemData = cached_system_data[key]
		if nodes.has("systemInfo"):
			var system_info = nodes["systemInfo"]
			system_info.txt = "%d games (%d favorites)" % [system_data.num_games, 0]
			# Seems like "systemInfo"'s position is relative to center
			system_info.size.x = 1024
			system_info.alignment = "center"
		if nodes.has("logo") and nodes["logo"].tex != null:
			var logo = nodes["logo"]
			logo.size = logo_size
			if type.find("wheel") != -1:
				logo.rot_pivot = logo_rot_pivot
			nodes.erase("logoText")
		else:
			var text = preload("res://objects/text/Text.tscn").instance()
			text.parsed = true
			text.txt = system_data.name
			text.color = Color(0, 0, 0, 1)
			text.font_path = "res://assets/fonts/Akrobat-SemiBold.ttf"
			text.font_size = 48
			nodes["logoText"] = text
			nodes.erase("logo")
		var extra_child = create_extra_child()
		var logo_child = create_logo_child(system_data)
		systems.push_back(system_data)
		for node_key in nodes:
			if node_key == "logo" or node_key == "logoText":
				logo_child.add_child(nodes[node_key])
			else:
				extra_child.add_child(nodes[node_key])
			nodes[node_key].apply_theme()
	pack()

func create_extra_child():
	var child := preload("res://views/system/SystemExtra.tscn").instance()
	child.should_hide = true
	child.visible = false
	n_extra_children.add_child(child)
	return child

func create_logo_child(system_data: RetroHubSystemData):
	var child = preload("res://views/system/SystemLogo.tscn").instance()
	child.system_data = system_data
	child.alignment = logo_align
	child.selected_scale = logo_scale
	child.set_selected(false)
	n_logo_children.add_child(child)
	return child

func get_selected_system_data() -> RetroHubSystemData:
	for child in n_logo_children.get_children():
		if child.selected:
			return child.system_data
	return null

func move_ui(steps: int):
	if steps < 0:
		# Sliding to the right; tail must go to head
		var head_child = n_logo_children.get_child(_head_idx)
		var head_pos = head_child.target_pos - move_stride
		n_logo_children.get_child(_tail_idx).set_pos(head_pos)
	elif steps > 0:
		# Sliding to the left; head must go to tail
		var tail_child = n_logo_children.get_child(_tail_idx)
		var tail_pos = tail_child.target_pos + move_stride
		n_logo_children.get_child(_head_idx).set_pos(tail_pos)

	var curr_extra = get_extra_for_idx(_curr_idx)
	var next_extra
	if steps < 0:
		next_extra = get_extra_for_idx(_curr_idx-1)
	else:
		next_extra = get_extra_for_idx(_curr_idx+1)

	_curr_idx = get_abs_idx(_curr_idx + steps)
	_tail_idx = get_abs_idx(_tail_idx + steps)
	_head_idx = get_abs_idx(_head_idx + steps)
	for i in range(system_count):
		var child = n_logo_children.get_child(i)
		child.move(-steps * move_stride, 0, i == _curr_idx)
	
	# Handle extra children as well
	var move_extra_delta = Vector2(1024, 0)
	if not next_extra.visible or abs(next_extra.rect_position.x) > move_extra_delta.x:
		next_extra.set_pos(move_extra_delta * steps)
	curr_extra.move(-steps * move_extra_delta, true)
	next_extra.move(-steps * move_extra_delta, false)
