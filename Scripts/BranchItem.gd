class_name BranchItem
extends Draggable

# The sentence number, tracks the sentences position in the current branch
# -1 if the sentence is not in a branch
var senNumber = -1;
@export var padding = 10;
var h = 10;
@export var curveRadius = 50;

# Variable for preloading the hook
var hook = preload("res://Nodes/hook.tscn");

# Variables for allowing hook numbers to vary:
var allowLeftVary = true;
var allowRightVary = true;

# Number of left & Right hooks
var leftHooks = 1;
var rightHooks = 1;

var LeftCircles : Object;
var RightCircles : Object;

# Charge is pm 1, determines whether two sentences can connect or not
# If charge is 0, then its neutral and can connect with all
@export var charge = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	_standard_ready();

func _standard_ready():
	highlightBox = $PanelContainer/Highlight;
	LeftCircles = $LeftCircles;
	RightCircles = $RightCircles;
	add_to_group("Clickable");
	add_to_group("BranchItem");
	h = 10;
	for i in range(leftHooks): 
		var temp = hook.instantiate();
		temp.mutable = allowLeftVary;
		temp.radius = -curveRadius;
		$LeftCircles.add_child(temp);
	for j in range(rightHooks): 
		var temp = hook.instantiate();
		temp.mutable = allowRightVary;
		temp.radius = curveRadius;
		$RightCircles.add_child(temp);
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# From parent
	_drag();
	# Move the anchors for the arrows between sentences & inference rules
	_position_circles();

# Called whenever the mouse is let go while dragging (from parent is false)
func _dropped():
	# Set the sentenece number to -1 in case the _check_add call is utterly a failure
	senNumber = -1;
	# Look for a branch to place sentence in, see Branches class
	get_tree().call_group("Branches", "_check_add", self);
	
	# Handle the case of no branch being selected
	if (senNumber != -1): return
	
	# Move sentence to the root
	var temp = get_tree().root.get_child(0);
	self.get_parent().remove_child(self);
	temp.add_child(self)
	
	# Update the branches position
	global_position = get_global_mouse_position() - offset;
	
	# Call the select function
	_select();

# Position the anchors used for connecting sentences & rules
func _position_circles():
	# Get midpoint of box
	var center = get_child(0).global_position + get_child(0).get_global_rect().size/2;
	# Set a radius (distance from center)
	var radius = Vector2(get_child(0).get_global_rect().size.x/2 + 10, 0);
	#Position circle centers accordingly
	$LeftCircles.global_position = center - radius;
	$RightCircles.global_position = center + radius;
	
	var step = h + padding;
	#var yLeft = ($LeftCircles.get_child_count()*step - padding)/2;
	var yLeft = 0;
	for i in $LeftCircles.get_children():
		i.position = Vector2(yLeft, 0);
		yLeft -= step;

	#var yRight = ($RightCircles.get_child_count()*step - padding)/2;
	var yRight = 0;
	for i in $RightCircles.get_children():
		i.position = Vector2(yRight, 0);
		yRight += step;
		

# Getters & setters
func _set_senNumber(value):
	senNumber = value;
	
func _select():
	pass
