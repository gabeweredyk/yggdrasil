extends MenuBar

var elimRules = ["and_elim", "or_elim", "neg_elim", "cond_elim", "bicond_elim", "contra_elim"];
var introRules = ["and_intro", "or_intro", "neg_intro", "cond_intro", "bicond_intro", "contra_intro"];
var decompRules = ["partial_decomposition", "decomposition", "alpha_decomposition", "beta_decomposition", "split", "merge"];

func _on_elim_pressed(id:int):
	var temp = InputEventAction.new();
	temp.action = elimRules[id];
	temp.pressed = true;
	Input.parse_input_event(temp);
func _on_intro_pressed(id:int):
	var temp = InputEventAction.new();
	temp.action = introRules[id];
	temp.pressed = true;
	Input.parse_input_event(temp);
func _on_decomp_pressed(id:int):
	var temp = InputEventAction.new();
	temp.action = decompRules[id];
	temp.pressed = true;
	Input.parse_input_event(temp);
