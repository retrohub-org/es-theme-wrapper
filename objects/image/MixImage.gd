extends Control

@onready var box_size : Vector2 = $Box.size

func parse_media_data(data: RetroHubGameMediaData) -> void:
	if data:
		$Screenshot.texture = data.screenshot
		$Logo.texture = data.logo
		$Box.texture = data.box_render
		if data.box_render.get_width() > data.box_render.get_height():
			# Box is horizontal: rotate to accomodate image better
			$Box.pivot_offset = Vector2(box_size.y, box_size.x) / 2
			$Box.size = Vector2(box_size.y, box_size.x)
			$Box.rotation = 90
		else:
			# Box is vertical; nothing needed to change
			$Box.pivot_offset = box_size / 2
			$Box.size = box_size
			$Box.rotation = 0
		$Support.texture = data.support_render
	else:
		$Screenshot.texture = null
		$Logo.texture = null
		$Box.texture = null
		$Support.texture = null
