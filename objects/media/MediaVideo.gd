extends VideoStreamPlayer

var video_len : int = 0

func stop():
	super.stop()
	$Delay.stop()

func _process(delta):
	if is_playing() and stream_position >= video_len:
		stream_position = 0

func parse_theme_xml(data: Dictionary) -> void:
	pass

func parse_media_data(data: RetroHubGameMediaData) -> void:
	if data.video:
		stream = data.video
		# src: https://github.com/kidrigger/godot-videodecoder/blob/master/test/World.gd
		# hack: to get the stream length, set the position to a negative number
		# the plugin will set the position to the end of the stream instead.
		stream_position = -1
		video_len = stream_position
		stream_position = 0
		$Delay.start()
	else:
		stream = null
