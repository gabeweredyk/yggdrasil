extends Hook
class_name BranchHook

var externallyJustified = false;

func _init():
	mutable = true;

func _process(delta):
	# Update the center of the hook
	center = global_position;
	var x1 = get_global_mouse_position();
	if (is_start_point): x1 = child_hook.global_position;
	childCurve._set_points(radius, center, x1);
	
	_indicate_status();
	
func _indicate_status():
	satisfied = false;
	if assumed:
		satisfied = true;
		externallyJustified = false;
	if is_end_point and origin_hook._get_attached().charge == -1:
		satisfied = origin_hook._get_attached().valid;
		externallyJustified = false;
	elif not satisfied:
		for j in get_parent().get_children():
			if (j.satisfied and not j.externallyJustified):
				satisfied = true
				externallyJustified = true
				
	var color : Color;
	
	if (assumed):
		color = Color.CYAN;
	elif satisfied:
		color = Color.GREEN;
	else:
		color = Color.WHITE;
		
	if is_start_point:
		childCurve.get_child(0).self_modulate = color;
	elif is_end_point:
		origin_hook.childCurve.get_child(3).self_modulate = color;
	else:
		self_modulate = color;
		
	if is_start_point and satisfied and child_hook.satisfied:
		childCurve.self_modulate = Color.GREEN;
	else:
		childCurve.self_modulate = Color.WHITE;
