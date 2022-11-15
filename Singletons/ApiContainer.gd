extends Node

var api_file = "res://api_keys.json"
var SUBJECT_SCHEDULE_API = null

func _ready() -> void:
	var f = File.new()
	f.open(api_file, File.READ)
	var whole_json = parse_json(f.get_as_text())
	SUBJECT_SCHEDULE_API = whole_json["SUBJECT-SCHEDULE-API"]
