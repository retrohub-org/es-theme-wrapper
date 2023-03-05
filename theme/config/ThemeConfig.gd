extends VBoxContainer

onready var n_path := $"%Path"
onready var n_load_path := $"%LoadPath"

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHubConfig.connect("theme_config_ready", self, "_on_theme_config_ready")
	var res = RetroHubUI.load_app_icon(RetroHubUI.Icons.LOAD)
	n_load_path.icon = res

func grab_focus():
	n_path.grab_focus()

func _on_theme_config_ready():
	n_path.text = RetroHubConfig.get_theme_config("path", "")

func _on_Path_text_changed(new_text):
	RetroHubConfig.set_theme_config("path", new_text)


func _on_LoadPath_pressed():
	RetroHubUI.filesystem_filters([])
	RetroHubUI.request_folder_load(n_path.text)
	var path : String = yield(RetroHubUI, "path_selected")
	n_path.text = path
	_on_Path_text_changed(path)
