extends Control

@onready var n_logo_bar := $Pivot/ColorBar
@onready var n_logo_children := $Pivot/Children
@onready var n_extra_children := $Children
var system_count : int
var _head_idx
var _curr_idx
var _tail_idx
var move_stride : Vector2

var systems := []

var PropertyWrapper = preload("res://PropertyWrapper.gd").new()

var parsed := false
var es_position := Vector2(0, 0.38375 * PropertyWrapper.screen_height)
@export var size_set := false
@export var es_size := Vector2(1 * PropertyWrapper.screen_width, 0.2325 * PropertyWrapper.screen_height)
@export var es_pos_origin := Vector2(0, 0)
var es_type := "horizontal"
var es_color := Color("ffffffd8")
var es_logo_size := Vector2(0.25 * PropertyWrapper.screen_width, 0.155 * PropertyWrapper.screen_height)
var es_logo_scale := 1.2
var es_logo_rotation := 7.5
var es_logo_rot_pivot := Vector2(-5 * PropertyWrapper.screen_width, 0.5 * PropertyWrapper.screen_height)
var es_logo_align := "center"
var es_max_logo_count := 3
@export var es_z_index := 10

func parse_theme_xml(Wrapper, data: Dictionary, _root_path: String):
	parsed = true
	for key in data:
		match key:
			"pos":
				es_position = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"size":
				es_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"origin":
				es_pos_origin = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"type":
				es_type = PropertyWrapper.parse_string(Wrapper, data[key])
			"color":
				es_color = PropertyWrapper.parse_color(Wrapper, data[key])
			"logoSize":
				es_logo_size = PropertyWrapper.parse_normalized_pair(Wrapper, data[key])
			"logoScale":
				es_logo_scale = PropertyWrapper.parse_float(Wrapper, data[key])
			"logoRotation":
				es_logo_rotation = PropertyWrapper.parse_float(Wrapper, data[key])
			"logoRotationOrigin":
				es_logo_rot_pivot = PropertyWrapper.parse_normalized_pair(Wrapper, data[key], false)
			"logoAlignment":
				es_logo_align = PropertyWrapper.parse_string(Wrapper, data[key])
			"maxLogoCount":
				es_max_logo_count = int(ceil(PropertyWrapper.parse_float(Wrapper, data[key])))
			"zIndex":
				es_z_index = int(round(PropertyWrapper.parse_float(Wrapper, data[key])))
				pass

func apply_theme():
	if not parsed:
		return

	$Pivot.position = es_position
	$Pivot.size = es_size
	es_pos_origin.x *= size.x
	es_pos_origin.y *= size.y
	$Pivot.position -= es_pos_origin
	n_logo_bar.color = es_color

func _gui_input(ev):
	if system_count > 1:
		if ev.is_action_pressed("ui_right", true):
			get_viewport().set_input_as_handled()
			move_ui(1)
		if ev.is_action_pressed("ui_left", true):
			get_viewport().set_input_as_handled()
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
	var bar_width = $Pivot/ColorBar.size.x / PropertyWrapper.screen_width
	move_stride = Vector2(((PropertyWrapper.screen_width - (es_logo_size.x * es_max_logo_count)) / (es_max_logo_count)) + es_logo_size.x, 0);
	move_stride.x *= bar_width
	for rel_idx in range(-2, system_count - 2):
		var idx = get_abs_idx(rel_idx)
		var pos = Vector2((PropertyWrapper.screen_width * bar_width / 2) + move_stride.x * (rel_idx), $Pivot/ColorBar.size.y / 2)
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
			system_info.es_txt = "%d games (%d favorites)" % [system_data.num_games, 0]
			# Seems like "systemInfo"'s position is relative to center
			system_info.es_size.x = PropertyWrapper.screen_width
			system_info.es_alignment = "center"
		if nodes.has("logo") and nodes["logo"].es_tex != null:
			var logo = nodes["logo"]
			logo.es_size = es_logo_size
			if es_type.find("wheel") != -1:
				logo.es_rot_pivot = es_logo_rot_pivot
			#warning-ignore:return_value_discarded
			nodes.erase("logoText")
		else:
			var text = preload("res://objects/text/Text.tscn").instantiate()
			text.parsed = true
			text.es_txt = system_data.name
			text.es_color = Color(0, 0, 0, 1)
			text.es_font_path = "res://assets/fonts/Akrobat-SemiBold.ttf"
			text.es_font_size = 48
			text.es_alignment = "center"
			text.es_size = es_logo_size
			nodes["logoText"] = text
			#warning-ignore:return_value_discarded
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
	var child := preload("res://views/system/SystemExtra.tscn").instantiate()
	child.should_hide = true
	child.visible = false
	n_extra_children.add_child(child)
	return child

func create_logo_child(system_data: RetroHubSystemData):
	var child = preload("res://views/system/SystemLogo.tscn").instantiate()
	child.system_data = system_data
	child.alignment = es_logo_align
	child.selected_scale = es_logo_scale
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
	var move_extra_delta = Vector2(PropertyWrapper.screen_width, 0)
	if not next_extra.visible or abs(next_extra.position.x) > move_extra_delta.x:
		next_extra.set_pos(move_extra_delta * steps)
	curr_extra.move(-steps * move_extra_delta, true)
	next_extra.move(-steps * move_extra_delta, false)
