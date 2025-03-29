extends Node

var branch = preload("res://Nodes/branch.tscn")
var sentence = preload("res://Nodes/editable_sentence.tscn")
var rule = preload("res://Nodes/rule.tscn")

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("SaveableData")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
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
			get_node(i["parent"]).add_child(temp)
			get_node(i["parent"]).move_child(temp, i["index"]);
		else:
			get_tree().root.get_child(0).add_child(temp);
			temp.global_position = Vector2(i["pos_x"], i["pos_y"]);
	
	
