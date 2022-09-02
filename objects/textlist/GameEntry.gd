extends Button

signal selected(data)

var game_data : RetroHubGameData setget set_game_data
var height : float setget set_height
var style : StyleBoxTexture setget set_style
var font : DynamicFont setget set_font
var font_color : Color setget set_font_color
var font_color_selected : Color setget set_font_color_selected

func set_game_data(_game_data: RetroHubGameData) -> void:
	game_data = _game_data
	text = game_data.name

func set_height(_height: float) -> void:
	height = _height
	rect_min_size.y = height

func set_style(_style: StyleBoxTexture) -> void:
	style = _style
	add_stylebox_override("focus", style)

func set_font(_font: DynamicFont) -> void:
	font = _font
	add_font_override("font", font)

func set_font_color(_font_color: Color) -> void:
	font_color = _font_color
	add_color_override("font_color", font_color)

func set_font_color_selected(_font_color_selected: Color) -> void:
	font_color_selected = _font_color_selected
	add_color_override("font_color_focus", font_color_selected)

func _ready():
	RetroHubConfig.connect("game_data_updated", self, "_on_game_data_updated")

func _on_game_data_updated(_game_data: RetroHubGameData):
	if game_data == _game_data:
		set_game_data(game_data)

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

