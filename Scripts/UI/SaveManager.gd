extends PopupMenu
class_name SaveManager

# Load the sentences & branches to be instantiated
var sentence = preload("res://Nodes/editable_sentence.tscn");
var branch = preload("res://Nodes/branch.tscn");
var rule = preload("res://Nodes/rule.tscn");
var hook = preload("res://Nodes/hook.tscn");

var current_save : String;
var inputHandler;

@onready var fd_save = $SaveDialog;
@onready var fd_load = $LoadDialog;
@onready var fd_reset = $ResetDialog;

var busy = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	fd_load.hide();
	fd_save.hide();
	fd_reset.hide();
	inputHandler = get_node("/root/Workspace/InputHandler");
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_id_pressed(id):
	match id:
		0: smooth_save()
		1: fd_save.show();
		2: fd_load.show();
		3: fd_reset.show();

func smooth_save():
	if (current_save != ""): save_game(current_save)
	else: fd_save.show();

func reset():
	fd_reset.hide();
	inputHandler.temp_last_selected = null;
	inputHandler.last_selected = null;
	var save_nodes = get_tree().get_nodes_in_group("SaveableData")
	for i in save_nodes: i.queue_free()

func save_game(path:String):
	fd_save.hide();
	busy = true;
	print("This is path: " + path)
	current_save = path;
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("SaveableData")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)
		
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	busy = false;
		
func load_game(path:String):
	fd_load.hide();
	busy = true;
	if not FileAccess.file_exists(path):
		return # Error! We don't have a save to load.
		
	current_save = path;
	get_window().title = path;
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	inputHandler.temp_last_selected = null;
	inputHandler.last_selected = null;
	var save_nodes = get_tree().get_nodes_in_group("SaveableData")
	for i in save_nodes: i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(path, FileAccess.READ)
	var branches = [];
	var branchItems = [];
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		if node_data["type"] == "Branch": branches.append(node_data)
		else: branchItems.append(node_data)
	
	for b in branches:
		var temp = branch.instantiate();
		get_tree().root.get_child(0).add_child(temp);
		temp.name = b["name"];
		temp.global_position = Vector2(b["pos_x"], b["pos_y"]);
		
	for i in branchItems:
		var temp;
		if i["type"] == "Sentence":
			temp = sentence.instantiate();
			temp._set_text(i["text"])
		elif i["type"] == "Rule":
			temp = rule.instantiate();
			temp.set_script(load(i["rule"]));
		temp.name = i["name"];
		if i["inBranch"]:
			print(i["parent"]);
			get_node(i["parent"]).add_child(temp)
			get_node(i["parent"]).move_child(temp, i["index"]);
		else:
			get_tree().root.get_child(0).add_child(temp);
			temp.global_position = Vector2(i["pos_x"], i["pos_y"]);
			
	for x in (branches + branchItems):
		var temp = get_node(x["parent"] + "/" + x["name"]);
		var fromRight = x["type"] == "Sentence";
		for j in x["to"]:
			var child = get_node(j);
			if fromRight or child.charge == -1:
				connect_normal(temp.RightCircles,child.RightCircles)
			else:
				connect_normal(temp.LeftCircles,child.LeftCircles)
		if not x["assumed"]: continue
		
		var assume_hook = null;
		for h in temp.LeftCircles.get_children():
			if h.is_start_point or h.is_end_point: continue;
			assume_hook = h;
			break;
		if (assume_hook == null):
			assume_hook = temp.LeftCircles.get_child(-1).duplicate();
			temp.LeftCircles.add_child(assume_hook);
			
		assume_hook.assumed = true;
	busy = false;

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
