extends Control

# Load the sentences & branches to be instantiated
var sentence = preload("res://Nodes/editable_sentence.tscn");
var branch = preload("res://Nodes/branch.tscn");
var rule = preload("res://Nodes/rule.tscn");
var hook = preload("res://Nodes/hook.tscn");

var ruleNames = ["merge", "split", "decomposition", "partial_decomposition", "alpha_decomposition", "beta_decomposition", "and_intro", "and_decomp", "and_elim", "or_intro", "or_elim", "neg_intro", "neg_elim", "cond_intro", "cond_elim", "bicond_intro", "bicond_elim", "contra_intro", "contra_elim"];

var last_selected : Object;
var temp_last_selected = null;

var saveManager : SaveManager;

# Get the camera
@export var camera : MapCamera2D;

func _ready():
	saveManager = get_node("/root/Workspace/CanvasLayer/Control/File");

# This node lives solely for the inputs
func _input(event):
	if (last_selected != null): last_selected.highlight = false;
	last_selected = temp_last_selected
	if (last_selected != null): last_selected.highlight = true;
	
	# If the event is a left mouse click
	if (event is InputEventMouseButton and event.pressed):
		# Get all nodes that are deemed clickable
		var clickables = get_tree().get_nodes_in_group("Clickable");
		# Store the highest z-index that the loop encounters
		var highestIndex = -1;
		# To store the selected node
		var selected = null;
		
		# Loop over all clickable nodes
		for s in clickables:
			# If s is a curve generator & clicked properly, turn off camera drag
			if (s.is_in_group("Hooks")):
				if ((get_global_mouse_position() - s.center).length_squared() <= s.r):
					print("Highlight to null!");
					temp_last_selected = null;
					camera.drag = false;
					return;
				continue;
				
			# If the mouse is not in the rect of the clickable, continue
			if (not s.get_child(0).get_global_rect().has_point(get_global_mouse_position())): continue
			
			# Check to see if the index of the target is higher than already selected or if the previously selected target was a branch
			if (s.get_index() >= highestIndex or selected.is_in_group("Branches")):
				# update selected & highest Index accordingly
				selected = s;
				highestIndex = s.get_index();
				
		# If nothing was selected, break early
		if (selected == null): return 
			
		if (event.button_index == MOUSE_BUTTON_RIGHT):
			for i in selected.get_child(1).get_children() + selected.get_child(2).get_children():
				i._turn_to_none();
			print("Highlight to null")
			temp_last_selected = null;
			selected.queue_free();
			
		if (not event.button_index == MOUSE_BUTTON_LEFT): return
		
		if (Input.is_key_pressed(KEY_SHIFT)):
			var temp = selected.duplicate();
			get_parent().add_child(temp);
			print("Highlight to clone");
			temp_last_selected = temp;
			return
			
		elif (Input.is_key_pressed(KEY_CTRL) and last_selected != null):
			print("Highlight kept the same")
			temp_last_selected = last_selected;
			if (last_selected.charge == -1 and selected.charge == 0):
				connect_normal(last_selected.LeftCircles,selected.LeftCircles);
			elif (last_selected.charge == 0 and selected.charge == -1):
				connect_normal(last_selected.RightCircles,selected.RightCircles);
			elif (last_selected.charge == 0 and selected.charge == 0):
				connect_sentences(last_selected,selected);
			return
			
		elif (Input.is_key_pressed(KEY_ALT) and last_selected != null):
			print("Highlight kept to same")
			temp_last_selected = last_selected;
			if (last_selected.charge == -1 and selected.charge == 0):
				connect_normal(selected.RightCircles,last_selected.RightCircles);
			elif (last_selected.charge == 0 and selected.charge == -1):
				connect_normal(selected.LeftCircles,last_selected.LeftCircles);
			elif (last_selected.charge == 0 and selected.charge == 0):
				connect_sentences(selected,last_selected);
			return
		
		# Start dragging the selected object
		print("Highlight updated to the selected object");
		temp_last_selected = selected;
		selected.dragging = true;
		selected._update_offset();
		
		# If selected is a sentence not in a branch
		if (not selected.get_parent().is_in_group("BranchBox") and (selected.is_in_group("Sentences") or selected.is_in_group("Rules"))):
			# Move to the front of zplane
			selected.get_parent().move_child(selected, -1);
			selected._set_senNumber(-1);
		
	# If the mouse is released, the camera is allowed to pan again
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		camera.drag = true;
		
	# If the input is a click from the right mouse button, try to delete a curve
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		var curves = get_tree().get_nodes_in_group("Bezier");
		for c in curves:
			var point = c.curve.get_closest_point(c.get_local_mouse_position());
			if ((point - c.get_local_mouse_position()).length_squared() <= 10):
				c.get_parent()._turn_to_none();
				c.drawing_curve = false;
				return

	# If the event is to create a sentence	
	elif (event.is_action_pressed("create_sentence")):
		var temp = sentence.instantiate();
		var parent;
		if (last_selected == null): parent = get_tree().root.get_child(0);
		elif (last_selected.is_in_group("Branches")): parent = last_selected.con; 
		else: parent = last_selected.get_parent();
		parent.add_child(temp);
		if last_selected != null and last_selected.is_in_group("Branches"):
			parent.move_child(temp,-1);
		elif parent.is_in_group("BranchBox"):
			parent.move_child(temp,last_selected.get_index() + 1);
		else:
			temp.global_position =  get_global_mouse_position() - temp.size/2;
		print("Move highlight to new sentence")
		temp_last_selected = temp;
		temp._select();

	# If the event is to create a branch
	elif (event.is_action_pressed("create_branch")):
		var temp = branch.instantiate();
		get_tree().root.get_child(0).add_child(temp);
		temp.global_position =  get_global_mouse_position() - temp.size/2;
		print("Move highlight to new branch")
		temp_last_selected = temp;
		
	elif (event.is_action_pressed("save")): 
		saveManager.smooth_save();
		
	elif (event.is_action_pressed("load")):
		saveManager.fd_load.show();
	
	else:
		for x in ruleNames:
			if (event.is_action_pressed(x)):
				_create_rule(x);
				return
				
func _create_rule(ruleType:String):
	var temp = rule.instantiate();
	temp.set_script(load("res://Scripts/Rules/" + ruleType + ".gd"));
	var parent;
	if (last_selected == null): parent = get_tree().root.get_child(0);
	elif (last_selected.is_in_group("Branches")): parent = last_selected.con; 
	else: parent = last_selected.get_parent();
	parent.add_child(temp);
	if last_selected != null and last_selected.is_in_group("Branches"):
		parent.move_child(temp,-1);
	elif parent.is_in_group("BranchBox"):
		parent.move_child(temp,last_selected.get_index() + 1);
	else:
		temp.global_position =  get_global_mouse_position() - temp.size/2;
	print("Move highlight to new rule")
	temp_last_selected = temp;
	return temp;
	
func connect_normal(from:Node2D,to:Node2D):
	var from_hook = null;
	for h in from.get_children():
		if h.is_start_point or h.is_end_point: continue;
		from_hook = h;
		break;
	if (from_hook == null):
		from_hook = from.get_child(-1).duplicate();
		from.add_child(from_hook);
		
	var to_hook = null;
	for h in to.get_children():
		if h.is_start_point or h.is_end_point: continue;
		to_hook = h;
		break;
	if (to_hook == null):
		to_hook = to.get_child(-1).duplicate();
		to.add_child(to_hook);
		
	from_hook._turn_to_start(to_hook);
	to_hook._turn_to_end(from_hook);
	from_hook.childCurve.drawing_curve = true;
	from_hook.childCurve.get_child(3).global_position = to_hook.global_position;
	
func connect_sentences(sen1:Draggable,sen2:Draggable,rule="partial_decomposition"):
	var temp = _create_rule(rule);
	connect_normal(sen1.RightCircles, temp.RightCircles);
	connect_normal(temp.LeftCircles, sen2.LeftCircles);
	if (sen1.get_parent() == sen2.get_parent() and sen1.get_parent().is_in_group("BranchBox")):
		temp.get_parent().remove_child(temp);
		sen1.get_parent().add_child(temp);
		sen1.get_parent().move_child(temp, sen2.get_index());
	else:
		temp.global_position = (sen1.global_position + sen2.global_position)/2;
			
