extends Node

var image_media

@onready var n_media_video = $Detailed/Media/MediaVideo
@onready var n_media_image = $Detailed/Media/MediaImage

var has_video := false

func _ready():
	$Detailed/Media/MediaVideo/Delay.timeout.connect(_on_VideoDelay_timeout)

func set_games(games: Array) -> void:
	$Detailed.set_games(games)

func app_returned(data: RetroHubGameData) -> void:
	$Detailed.app_returned(data)

func reset() -> void:
	$Detailed.reset()

func get_focus():
	$Detailed.get_focus()

func on_show():
	$Detailed.on_show()

func on_hide():
	$Detailed.on_hide()
	n_media_image.visible = true
	n_media_video.visible = false
	n_media_video.stop()

func clear_game_media_cache():
	$Detailed.clear_game_media_cache()

func _on_game_entry_selected(data: RetroHubGameData):
	n_media_image.visible = true
	n_media_video.visible = false

func _on_VideoDelay_timeout():
	n_media_image.visible = false
	n_media_video.visible = true
	n_media_video.play()
