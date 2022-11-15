extends Control

onready var subject_list = $TabContainer/Assignments/VBoxContainer
export var schedule_box:PackedScene
export var subject_box:PackedScene

func _ready() -> void:
	
	if Cache.get_subject_dict() != null: #Loading cache
		update_subject_list(Cache.get_subject_dict())
		update_schedule(Cache.get_subject_dict())
		$TabContainer/Schedule.set_current_tab(Cache.get_subject_dict()["Weeknum"] - 1)
	$API.request(ApiContainer.SUBJECT_SCHEDULE_API)
	
	if OS.get_datetime()["weekday"] <= 5:
		$"TabContainer/Schedule/1".set_current_tab(OS.get_datetime()["weekday"] - 1)
		$"TabContainer/Schedule/2".set_current_tab(OS.get_datetime()["weekday"] - 1)

func _on_API_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var output = parse_json(body.get_string_from_utf8())
	update_subject_list(output)
	update_schedule(output)
	$TabContainer/Schedule.set_current_tab(Cache.get_subject_dict()["Weeknum"] - 1)
	
	
func update_subject_list(output: Dictionary):
	
	var expired_subject_count:int = 0
	
	for i in subject_list.get_children(): #Clearing the previous list
		i.queue_free()
		
	var m = MarginContainer.new() #Making margin container on top
	subject_list.add_child(m)
	
	
	for i in range(output["Subjects"].size()): #Printing the entire Subjects category

		var subject_box_instance = subject_box.instance()
		
		var date: String = output["Subjects"][str(i)]["date"]
		var formated_date: String = ""
		for j in range(10):
			formated_date += date[j]
		
		var days_left: int = ((Time.get_unix_time_from_datetime_string(formated_date) - Time.get_unix_time_from_system()) / 86400)
		
		
		if days_left <= 0:
			expired_subject_count += 1
			var new_override: StyleBoxFlat = load("res://Resources/Styles/SubjectBoxStyleBox.tres").duplicate()
			new_override.bg_color = Color("0A0A0B")
#			new_override.shadow_size = 0
#			new_override.border_width_bottom = 0
#			new_override.border_width_left = 0
#			new_override.border_width_right = 0
#			new_override.border_width_top = 0
			subject_box_instance.add_stylebox_override("panel", new_override)
		
		if days_left <= 5 and days_left >= 0:
			subject_box_instance.get_node("Control/Date").set_text(formated_date + "\n" + str(days_left+1) + "d left")
		elif days_left <= 0:
			subject_box_instance.get_node("Control/Date").set_text(formated_date)
		else:
			subject_box_instance.get_node("Control/Date").set_text(output["Subjects"][str(i)]["date"])
		subject_box_instance.get_node("FirstHalf/Subject").set_text(output["Subjects"][str(i)]["Subject"])
		subject_list.add_child(subject_box_instance)
	m = MarginContainer.new() #Making margin container on bottom
	subject_list.add_child(m)
	
	yield(get_tree().create_timer(0),"timeout") #Gali bandyt komentuot sita eilute ir ziuret kas gausis
	# As speju jam reikia sito yieldo, nes nesvarbu koks timeris, jis vstk pra yield'ins bent 1 frame
	# Ir tas palauktas frame, pries setinant scroll vertical tikriausiai daro all the differnce in the world
	# Aisku, galima yeildinti "idle_frame" arba "physics_frame", bet tokiu budu tas bugas vistiek islieka, even tho buvo praleistas 1 frame.
	
	$TabContainer/Assignments.set_deferred("scroll_vertical", expired_subject_count * 283)
	
	Cache.save_subjects_dict(output)


func update_schedule(output: Dictionary):
	
	for i in get_tree().get_nodes_in_group("schedual_container"):
		for j in i.get_children():
			j.queue_free()
	
	update_week("Week_1", "Monday", output)
	update_week("Week_1", "Tuesday", output)
	update_week("Week_1", "Wednesday", output)
	update_week("Week_1", "Thursday", output)
	update_week("Week_1", "Friday", output)
	
	update_week("Week_2", "Monday", output)
	update_week("Week_2", "Tuesday", output)
	update_week("Week_2", "Wednesday", output)
	update_week("Week_2", "Thursday", output)
	update_week("Week_2", "Friday", output)
	pass
	
func update_week(weeknum: String, week: String, output: Dictionary):
	
	var a = MarginContainer.new()
	get_node("TabContainer/Schedule/" + weeknum[5] + "/" + week + "/VBoxContainer").add_child(a)
	
	for i in output["Schedule"][weeknum][week].values():
		var s = schedule_box.instance()
		s.get_node("Time").set_text(i["Time"])
		s.get_node("Name").set_text(i["Name"])
		s.get_node("Auditorium").set_text(i["Auditorium"])
		s.get_node("Type").set_text(i["Type"])
		
		
		if weeknum == "Week_1":
			get_node("TabContainer/Schedule/1/" + week + "/VBoxContainer").add_child(s)
		if weeknum == "Week_2":
			get_node("TabContainer/Schedule/2/" + week + "/VBoxContainer").add_child(s)
	pass


func _on_1_tab_changed(tab: int) -> void:
	$"TabContainer/Schedule/2".set_current_tab(tab)


func _on_2_tab_changed(tab: int) -> void:
	$"TabContainer/Schedule/1".set_current_tab(tab)
