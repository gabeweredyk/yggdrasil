extends PopupMenu

var events = ["create_sentence", "create_branch"]

func _on_press(id:int):
	var temp = InputEventAction.new();
	temp.action = events[id];
	temp.pressed = true;
	Input.parse_input_event(temp);
