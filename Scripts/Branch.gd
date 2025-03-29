# Script to be attached to branch objects
class_name Branch
extends Draggable

# Stores the node that actually holds the sentenecs
var con;
var charge = 1;

@export var padding = 10;
var h = 10;

var valid = false;

var LeftCircles : Object;
var RightCircles : Object;

# Called when the node enters the scene tree for the first time.
func _ready():
	LeftCircles = $TopHooks;
	RightCircles = $BottomHooks;
	highlightBox = $PanelContainer/Highlight
	# Gets the path of the BranchBox
	con = $PanelContainer/CenterContainer/MarginContainer/BoxContainer;
	# Add to Branches group
	add_to_group("Branches")
	# Add to clickable group
	add_to_group("Clickable");
	add_to_group("SaveableData");
	
	for i in LeftCircles.get_children(): i.radius = -50;
	for i in RightCircles.get_children(): i.radius = 50;

# Called when a sentence is dropped to every branch, if the sentance is in the rect, then the sentence is added
func _check_add(sen):
	if (get_child(0).get_global_rect().has_point(get_global_mouse_position())):
		_add_sentence(sen)

# Once the sentence is confirmed to be dropped in the branch, properly determine where to drop it
func _add_sentence(data):
	# Get the current mouse y position to propely index the sentence
	var m = get_global_mouse_position().y;
	# Set the index for checking through the children of the branch. By default, its the last index
	var i = con.get_child_count();
	# checkTwice is set to one if the current sentence is currently a sentence in the branch &
	# the code is checking if the sentence fits between sentences with a higher index
	var checkTwice = 0;
	# Loop over children
	for sen in con.get_children():
		# Increment checkTwice accordingly
		if (sen == data):
			checkTwice = 1
			continue
		# Get the midpoint y of the current sentences
		var y = sen.global_position.y + sen.size.y/2;
		
		# If the mouse is higher on the screen then the current branch, place it before the sentence in the branch
		if (m <= y):
			# Set the index i to the appropriate index based of the inequality & break early
			i = sen.get_index() - checkTwice;
			break
			
	
	# Set the index of the sentence to i
	data._set_senNumber(i);
	data.get_parent().remove_child(data);
	con.add_child(data);
	con.move_child(data, i);

	# Let the user edit the data
	data._select();
	
func _process(_delta):
	_drag();
	_position_circles();
	
func _position_circles():
	# Get midpoint of box
	var center = get_child(0).global_position + get_child(0).get_global_rect().size/2;
	# Set a radius (distance from center)
	var radius = Vector2(0, get_child(0).get_global_rect().size.y/2 + 10);
	#Position the hooks
	$TopHooks.global_position = center - radius;
	$BottomHooks.global_position = center + radius;
	
	var step = h + padding;
	#var yLeft = -($TopHooks.get_child_count()*step - padding)/2 + 5;
	var yLeft = 0;
	for i in $TopHooks.get_children():
		i.position = Vector2(0, -yLeft);
		yLeft += step;

	#var yRight = -($BottomHooks.get_child_count()*step - padding)/2 + 5;
	var yRight = 0;
	for i in $BottomHooks.get_children():
		i.position = Vector2(0, yRight);
		yRight += step;

func _get_branch():
	var assumptions = [];
	for hook in $TopHooks.get_children():
		if not hook.is_start_point: continue
		if not hook.child_hook._get_attached() is Sentence: continue
		assumptions.append( hook.child_hook._get_attached()._get_text() );
	var sentences = [];
	for item in con.get_children():
		if not (item is Sentence): continue
		sentences.append(item._get_text());
	return [assumptions, sentences];
	
func save():
	var assumed = false;
	for i in LeftCircles.get_children(): assumed = i.assumed or assumed;
	
	var to : Array;
	for i in (LeftCircles.get_children() + RightCircles.get_children()):
		if not i.is_start_point: continue
		to.append( str(i.child_hook._get_attached().get_path()).replace("@","_") );
		
	var save_dict = {
		"type" : "Branch",
		"name" : name.replace("@","_"),
		"parent" : str(get_parent().get_path()).replace("@", "_"),
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"assumed" : assumed,
		"to" : to
	}
	
	return save_dict;
