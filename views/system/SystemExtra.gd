extends Control

var cached_z_indexes := {}

var should_hide := true
var target_pos := Vector2(0, 0)

func _ready():
	for child in $Children.get_children():
		cached_z_indexes[child.name] = child

func add_child(node: Node, _force_readable_name: bool = false, _internal: InternalMode = 0) -> void:
	var z_index = node.get("es_z_index")
	if z_index == null:
		z_index = 10

	if not cached_z_indexes.has(str(z_index)):
		var idx = get_idx_for_z_index(z_index)
		var z_node = create_z_index_node()
		z_node.name = str(z_index)
		$Children.add_child(z_node, true)
		$Children.move_child(z_node, idx)
		cached_z_indexes[str(z_index)] = z_node

	cached_z_indexes[str(z_index)].add_child(node)

func create_z_index_node():
	var node := Control.new()
	node.anchor_right = 1
	node.anchor_bottom = 1
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func get_idx_for_z_index(z_index: int) -> int:
	var idx = 0
	for child in $Children.get_children():
		if child.name.to_int() > z_index:
			return idx
		idx += 1
	return idx

func _on_Tween_tween_completed():
	if should_hide:
		visible = false

func set_pos(pos: Vector2) -> void:
	position = pos
	target_pos = pos

func move(delta: Vector2, _should_hide: bool):
	should_hide = _should_hide
	target_pos += delta
	var tween := get_tree().create_tween()
	visible = true
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(
		self, "position",
		target_pos, 0.5
	)
	tween.tween_callback(_on_Tween_tween_completed)
