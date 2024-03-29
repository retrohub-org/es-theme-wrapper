@tool
extends Control

var system_data : RetroHubSystemData
var selected : bool = false
var alignment : String
var selected_scale : float = 1

var target_pos : Vector2
var target_rot : float

var tween : Tween = null

func center_nodes() -> void:
	for node in get_children():
		if node is Control:
			node.position = -node.size / 2

func set_pos(_position: Vector2) -> void:
	position = _position
	target_pos = _position

func set_rot(_rotation: float) -> void:
	rotation = _rotation
	target_rot = _rotation

func set_selected(_selected: bool) -> void:
	selected = _selected
	modulate.a = 1.0 if selected else 0.5
	scale = Vector2(selected_scale, selected_scale) if selected else Vector2(1, 1)

func move(delta_pos: Vector2, delta_rot: float, _selected: bool):
	target_pos += delta_pos
	target_rot += delta_rot
	selected = _selected
	if tween != null:
		tween.stop()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_parallel(true)
	tween.tween_property(
		self, "position",
		target_pos, 0.5
	)
	tween.tween_property(
		self, "rotation",
		target_rot, 0.5
	)
	tween.tween_property(
		self, "modulate:a",
		1.0 if selected else 0.5, 0.5
	)
	tween.tween_property(
		self, "scale",
		Vector2(selected_scale, selected_scale) if selected else Vector2(1, 1),
		0.5
	)
