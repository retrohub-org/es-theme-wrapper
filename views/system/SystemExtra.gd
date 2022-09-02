extends Control

onready var tween = $Tween

var cached_z_indexes := {}

var should_hide := true
var target_pos := Vector2(0, 0)

func _ready():
	for child in $Children.get_children():
		cached_z_indexes[child.name] = child

func add_child(node: Node, legible_unique_name: bool = false) -> void:
	var z_index = node.get("z_index")
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
		if int(child.name) > z_index:
			return idx
		idx += 1
	return idx

func _on_Tween_tween_completed(object, key):
	if should_hide:
		visible = false

func _on_Tween_tween_started(object, key):
	visible = true

func set_pos(position: Vector2) -> void:
	rect_position = position
	target_pos = position

func move(delta: Vector2, should_hide: bool):
	self.should_hide = should_hide 
	target_pos += delta
	#tween.stop_all()
	tween.interpolate_property(
		self, "rect_position",
		null, target_pos, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.start()
