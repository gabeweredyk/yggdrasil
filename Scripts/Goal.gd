extends Label
class_name Goal

func _ready():
	pass
	#add_to_group("SaveableData");
	
func save():
	var save_dict = {
		"type" : "Goal",
		"name" : name.replace("@","_"),
		"goal" : text,
		"index" : get_index()
	}
	
	return save_dict;
