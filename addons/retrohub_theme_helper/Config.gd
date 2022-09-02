extends Node

signal config_ready(config_data)
signal config_updated(key, old_value, new_value)
signal system_data_updated(system_data)
signal game_data_updated(game_data)
signal game_media_data_updated(game_media_data)

var games : Array
var systems : Dictionary
var systems_raw : Dictionary
var emulators : Array
var emulators_map : Dictionary

var _dir := Directory.new()

func get_config_dir() -> String:
	match FileUtils.get_os_id():
		FileUtils.OS_ID.WINDOWS:
			return FileUtils.get_home_dir() + "/RetroHub"
		_:
			return FileUtils.get_home_dir() + "/.retrohub"

func get_config_file() -> String:
	return get_config_dir() + "/rh_config.json"

func get_systems_file() -> String:
	return get_config_dir() + "/rh_systems.json"

func get_emulators_file() -> String:
	return get_config_dir() + "/rh_emulators.json"

func get_themes_dir():
	return get_config_dir() + "/themes"

func get_gamelists_dir():
	return get_config_dir() + "/gamelists"

func get_gamemedia_dir():
	return get_config_dir() + "/gamemedia"


