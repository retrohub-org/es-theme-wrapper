tool
extends Control

var system_data : RetroHubSystemData
var selected : bool = false
var alignment : String
var selected_scale : float = 1

onready var tween = $Tween

var target_pos : Vector2
var target_rot : float

func center_nodes() -> void:
	for node in get_children():
		if node is Control:
			node.rect_position = -node.rect_size / 2

func set_pos(position: Vector2) -> void:
	rect_position = position
	target_pos = position

func set_rot(rotation: float) -> void:
	rect_rotation = rotation
	target_rot = rotation

func set_selected(_selected: bool) -> void:
	selected = _selected
	modulate.a = 1.0 if selected else 0.5
	rect_scale = Vector2(selected_scale, selected_scale) if selected else Vector2(1, 1)

func move(delta_pos: Vector2, delta_rot: float, _selected: bool):
	target_pos += delta_pos
	target_rot += delta_rot
	tween.stop_all()
	selected = _selected
	tween.interpolate_property(
		self, "rect_position",
		null, target_pos, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "rect_rotation",
		null, target_rot, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate:a",
		null, 1.0 if selected else 0.5, 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "rect_scale", null,
		Vector2(selected_scale, selected_scale) if selected else Vector2(1, 1),
		0.5, Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.start()
