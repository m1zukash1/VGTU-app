extends Node

var cache_file = "user://VGTU-3rd-part-app.cachefile" # dont touch the spikes clone save file
var Delete_Save_File = false # Used for debugging purposes

func _ready() -> void:
	if Delete_Save_File:
		delete_save()

func delete_save():
	var f = Directory.new()
	f.remove(cache_file)
	pass

func save_subjects_dict(dict: Dictionary):
	var f = File.new()
	f.open(cache_file, File.WRITE)
	
	f.store_var(dict)
	
	
func get_subject_dict():
	var f = File.new()
	if f.file_exists(cache_file):
		f.open(cache_file, File.READ)
		return f.get_var()
	else:
		return 
