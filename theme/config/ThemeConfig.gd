extends VBoxContainer

onready var n_path := $"%Path"

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHubConfig.connect("theme_config_ready", self, "_on_theme_config_ready")

func _on_theme_config_ready():
	n_path.text = RetroHubConfig.get_theme_config("path", "")

func _on_Path_text_changed(new_text):
	RetroHubConfig.set_theme_config("path", new_text)
