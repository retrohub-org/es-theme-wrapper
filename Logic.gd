extends Node

export(String) var path

var Wrapper = load("res://Wrapper.gd").new()

var systems := {}

var games := {}
var games_metadata := {}

var gameview_map := {}

enum Mode {
	SYSTEM,
	GAME_VIEW
}

var curr_mode = Mode.SYSTEM

onready var target_position_system : Vector2 = $System.rect_position
onready var target_position_game_view : Vector2 = $GameView.rect_position

# _ready function, called everytime the theme is loaded
func _ready():
	# App related signals
	RetroHub.connect("app_initializing", self, "_on_app_initializing")
	RetroHub.connect("app_closing", self, "_on_app_closing")
	RetroHub.connect("app_received_focus", self, "_on_app_received_focus")
	RetroHub.connect("app_lost_focus", self, "_on_app_lost_focus")
	RetroHub.connect("app_returning", self, "_on_app_returning")

	# Content related signals
	RetroHub.connect("system_receive_start", self, "_on_system_receive_start")
	RetroHub.connect("system_received", self, "_on_system_received")
	RetroHub.connect("system_receive_end", self, "_on_system_receive_end")

	RetroHub.connect("game_receive_start", self, "_on_game_receive_start")
	RetroHub.connect("game_received", self, "_on_game_received")
	RetroHub.connect("game_receive_end", self, "_on_game_receive_end")
	
	# Config related signals
	RetroHubConfig.connect("config_updated", self, "_on_config_updated")
	RetroHubConfig.connect("theme_config_ready", self, "_on_theme_config_ready")
	RetroHubConfig.connect("theme_config_updated", self, "_on_theme_config_updated")

	if not RetroHub.is_main_app():
		Wrapper.load_es_theme_file(path + "/theme.xml")

func set_node_enabled(node: Node, enabled: bool):
	node.set_process(enabled)
	node.set_physics_process(enabled)
	node.set_process_input(enabled)
	node.set_process_unhandled_input(enabled)
	for child in node.get_children():
		if child is Node:
			set_node_enabled(child, enabled)

#_unhandled_input, called at every input event
# use this function for input (not _input/_process) for proper behavior
func _unhandled_input(event):
	if event.is_action_pressed("rh_accept") and curr_mode == Mode.SYSTEM:
		get_tree().set_input_as_handled()
		var system_data : RetroHubSystemData = $System.get_selected_system_data()
		var game_view = gameview_map[system_data]
		curr_mode = Mode.GAME_VIEW
		move_ui(1, game_view)
	if event.is_action_pressed("rh_back") and curr_mode == Mode.GAME_VIEW:
		get_tree().set_input_as_handled()
		curr_mode = Mode.SYSTEM
		move_ui(-1)
		RetroHub.set_curr_game_data(null)

func move_ui(dir: int, game_view: Node = null):
	var delta = Vector2(0, -dir * 600)
	target_position_game_view += delta
	target_position_system += delta
	if dir == -1:
		set_node_enabled($System, true)
		$System.grab_focus()
	for child in $GameView.get_children():
		if dir == 1:
			child.visible = child == game_view
			if child.visible:
				set_node_enabled(child, true)
				child.on_show()
		else:
			set_node_enabled(child, false)
			child.on_hide()
	$Tween.interpolate_property(
		$GameView, "rect_position",
		null, target_position_game_view,
		0.5, Tween.TRANS_QUART, Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		$System, "rect_position",
		null, target_position_system,
		0.5, Tween.TRANS_QUART, Tween.EASE_OUT
	)
	$Tween.start()

## Called when RetroHub is initializing your theme.
## This can either happen when RetroHub is launching, or
## the theme was changed to this one.
func _on_app_initializing(cold_boot : bool):
	pass

## Called when RetroHub is unitializing your theme.
## This can either happen when RetroHub is closing, or
## the theme was changed to another one.
##
## While this function can block for the duration needed
## (if, for example, you want a custom "exiting" animation),
## do not do anything that takes too long.
func _on_app_closing():
	pass

## Called when RetroHub window receives focus without any current game launched.
## Use this for any behavior desired (for example, re-enabling audio streams)
func _on_app_received_focus():
	pass

## Called when RetroHub window loses focus without any current game launched.
## Use this for any behavior desired (for example, muting audio streams)
func _on_app_lost_focus():
	pass

## Called when RetroHub is returning from a launched game back into focus.
## The way RetroHub works, signals "app_initialized", "app_received_focus",
## and all "system_received" and "game_received" signals are sent before this
## signal is fired, as themes are unloaded during games to reduce memory footprint.
##
## Use this signal to recreate the UI state as it was before launching the game.
func _on_app_returning(system_data: RetroHubSystemData, game_data: RetroHubGameData):
	var game_view = gameview_map[system_data]
	curr_mode = Mode.GAME_VIEW
	move_ui(1, game_view)
	game_view.app_returned(game_data)

## Called when RetroHub is about to send all system data.
func _on_system_receive_start():
	pass

## Called when RetroHub has information of a game system available.
## It's your job to display the system information in the UI. All the information
## given to you is only of currently detected systems, and not all systems that
## RetroHub supports.
##
## System information always arrives before game information.
func _on_system_received(data: RetroHubSystemData):
	# Load XML for given system
	if path:
		var system_path = path + "/" + Wrapper.convert_system_name(data.name) + "/theme.xml"
		Wrapper.load_es_theme_file(system_path)
		Wrapper.set_system_variables(data)
		$System.parse_theme_xml(Wrapper, system_path, data.name)
		$System.apply_theme()
		$System.add_system_data(data)
		systems[data.name] = data

## Called when RetroHub has finished sending all system data.
## Game data will follow immediately after that.
func _on_system_receive_end():
	pass

## Called when RetroHub is about to send all game data.
## At this point, all system data has been sent to the theme.
func _on_game_receive_start():
	pass

## Called when RetroHub has information of a game available.
## It's your job to display the game information, as well as a game list per system,
## in the UI. All the information given to you is only of currently available games.
##
## Game information always arrives after system information.
func _on_game_received(data: RetroHubGameData):
	if path:
		if games.has(data.system.name):
			games[data.system.name].push_back(data)
			if data.has_metadata:
				games_metadata[data.system.name] = data.has_metadata
		else:
			games[data.system.name] = [data]
			games_metadata[data.system.name] = data.has_metadata

## Called when RetroHub has finished sending all game data.
func _on_game_receive_end():
	if path:
		for system_name in games:
			var game_view
			if games_metadata[system_name]:
				game_view = load("res://views/detailed/Detailed.tscn").instance()
			else:
				game_view = load("res://views/basic/Basic.tscn").instance()
			$GameView.add_child(game_view)

			if systems.has(system_name):
				var system_data : RetroHubSystemData = systems[system_name]
				Wrapper.set_system_variables(system_data)
				var root_path = path + "/" + Wrapper.convert_system_name(system_name) + "/theme.xml"
				game_view.parse_theme_xml(Wrapper, root_path)
				game_view.apply_theme()
				game_view.set_system(system_data)
				game_view.set_games(games[system_name])
				set_node_enabled(game_view, false)
				game_view.visible = false
				gameview_map[system_data] = game_view

## Called when any config key has been changed
func _on_config_updated(key: String, old_value, new_value):
	if key == ConfigData.KEY_GAMES_DIR:
		print("Game folder changed, request reload")
		RetroHub.request_theme_reload()

func _on_theme_config_ready():
	# Load theme XML info
	path = RetroHubConfig.get_theme_config("path", "")
	print("Here, path: ", path)
	if not path.empty():
		Wrapper.load_es_theme_file(path + "/theme.xml")
	else:
		print("No path selected")

func _on_theme_config_updated(key, old_value, new_value):
	print(key)
	if key == "path":
		print("old: %s, new: %s, changing..." % [old_value, new_value])
		RetroHub.request_theme_reload()
