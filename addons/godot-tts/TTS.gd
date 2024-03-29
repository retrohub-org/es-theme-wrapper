@tool
extends Node

signal utterance_begin(utterance)

signal utterance_end(utterance)

signal utterance_stop(utterance)

var editor_accessibility_enabled : bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _get_min_rate():
	return 0


var min_rate : get = _get_min_rate


func _get_max_rate():
	return 0


var max_rate : get = _get_max_rate


func _get_normal_rate():
	return 0


var normal_rate : get = _get_normal_rate

var javascript_rate = self.normal_rate


func _set_rate(rate):
	pass


func _get_rate():
	return 0


var rate : get = _get_rate, set = _set_rate


func _get_rate_percentage():
	return remap(self.rate, self.min_rate, self.max_rate, 0, 100)


func _set_rate_percentage(v):
	self.rate = remap(v, 0, 100, self.min_rate, self.max_rate)


var rate_percentage : get = _get_rate_percentage, set = _set_rate_percentage


func _get_normal_rate_percentage():
	return remap(self.normal_rate, self.min_rate, self.max_rate, 0, 100)


var normal_rate_percentage : get = _get_rate_percentage


func speak(text, interrupt := true):
	return ""


func stop():
	pass


func _get_is_rate_supported():
	return false


var is_rate_supported : get = _get_is_rate_supported


func _get_are_utterance_callbacks_supported():
	return false


var are_utterance_callbacks_supported : get = _get_are_utterance_callbacks_supported


func _get_can_detect_is_speaking():
	return false


var can_detect_is_speaking : get = _get_can_detect_is_speaking


func _get_is_speaking():
	return false


var is_speaking : get = _get_is_speaking


func _get_can_detect_screen_reader():
	return false


var can_detect_screen_reader : get = _get_can_detect_screen_reader


func _get_has_screen_reader():
	return false


var has_screen_reader : get = _get_has_screen_reader


func singular_or_plural(count, singular, plural):
	if count == 1:
		return singular
	else:
		return plural
