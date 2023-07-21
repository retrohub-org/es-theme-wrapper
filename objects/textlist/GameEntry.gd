extends Button

signal selected(data)

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		text = game_data.name

var height : float:
	set(value):
		height = value
		custom_minimum_size.y = height

var style : StyleBoxTexture:
	set(value):
		style = value
		add_theme_stylebox_override("focus", style)

var font : FontFile:
	set(value):
		font = value
		add_theme_font_override("font", font)

var font_size : int:
	set(value):
		font_size = value
		add_theme_font_size_override("font_size", font_size)

var font_color : Color:
	set(value):
		font_color = value
		add_theme_color_override("font_color", font_color)

var font_color_selected : Color:
	set(value):
		font_color_selected = value
		add_theme_color_override("font_focus_color", font_color_selected)

func _ready():
	#warning-ignore:return_value_discarded
	RetroHubConfig.game_data_updated.connect(_on_game_data_updated)

func _on_game_data_updated(_game_data: RetroHubGameData):
	if game_data == _game_data:
		game_data = _game_data

func _on_GameEntry_pressed():
	RetroHub.launch_game()

func _on_GameEntry_focus_entered():
	if not RetroHub.is_input_echo():
		RetroHub.set_curr_game_data(game_data)
		emit_signal("selected", game_data)
	else:
		emit_signal("selected", null)


func _on_GameEntry_gui_input(event: InputEvent):
	if not event.is_pressed():
		if not RetroHub.is_input_echo() and has_focus():
			_on_GameEntry_focus_entered()

