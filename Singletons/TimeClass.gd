extends Node

func get_day_of_year_int_from_date_string(date: String) -> int:
	
	var months
	if get_year_int_from_date_string(date) % 4 == 0:
		months = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
	else:
		months = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
	
	return int(months[get_month_int_from_date_string(date) - 1] + get_day_int_from_date_string(date)) - 1

func get_year_int_from_date_string(date: String) -> int:
	return int(date[0]+date[1]+date[2]+date[3])

func get_month_int_from_date_string(date: String) -> int:
	return int(date[5]+date[6])
	
func get_day_int_from_date_string(date: String) -> int:
	return int(date[8]+date[9])
