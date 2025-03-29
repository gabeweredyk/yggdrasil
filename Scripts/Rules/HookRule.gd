# Script for anchors that connect rules & sentences
class_name HookRule
extends Sprite2D

# Store the center of the hook
var center = Vector2(0, 0);

# Preload the bezier curve node
var bezier = preload("res://Nodes/bezier_rule.tscn");

# Store the child curve
var childCurve : BezierRule;

# The radius of the circle
var r = 30;

# Booleans to determine behavior of the point
var is_end_point = false;
var is_start_point = false;

# Stores the connected hooks
var origin_hook : Object;
var child_hook : Object;

# Boolean that stores whether or not the user is making a curve
var dragging = false;

# Boolean that allows hooks to be deleted or created
var mutable = true;

# The desired distance the curvev sticks out
@export var radius : float;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add to appropriate groups
	add_to_group("Clickable");
	add_to_group("Hooks");
	# Create a bezier node as a child & initialize it properly
	childCurve = bezier.instantiate();
	add_child(childCurve);
	childCurve.global_position = global_position
	childCurve.drawing_curve = false;
	if (mutable):
		self_modulate = Color.WHITE;
	else:
		self_modulate = Color.DIM_GRAY;
	# Set r accurately
	r = get_viewport_rect().size.x/16;

func _input(event):
	# If the left mouse button is pressed
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		# If the mouse isn't in the hook, idgaf
		if ((get_global_mouse_position() - center).length_squared() > r): return
		# If the shift key is held down, create a new hook (and mutable)
		if (Input.is_key_pressed(KEY_SHIFT) and mutable):
			var temp = duplicate();
			get_parent().add_child(temp);
			temp._turn_to_none();
			return
		# Check to see if hook is currently a child_hook
		if (is_end_point):
			origin_hook.dragging = true;
			origin_hook._turn_to_none(true);
			_turn_to_none();
			return
		# Start dragging
		dragging = true;
		# Revert child hook if it exists
		if (is_start_point): child_hook._turn_to_none();
		# revoke being a start_point
		_turn_to_none();
		childCurve.drawing_curve = true;
		
	# If the right mouse button is clicked (and mutable is true)
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and mutable):
		# Check to make sure mouse is actually in position lol
		if ((get_global_mouse_position() - center).length_squared() > r): return
		# Dont delete if its the last in the partent
		if (get_parent().get_child_count() == 1): return
		# Turn any connecting points to nothin
		if (is_start_point): child_hook._turn_to_none();
		if (is_end_point): origin_hook._turn_to_none();
		# Die
		queue_free();
		
	# If the mouse is released while dragging is true
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and dragging):
		# Stop dragging (duh)
		dragging = false;
		
		# Look to see if mouse was released over another hook
		get_tree().call_group("Hooks", "_check_origin", self);
		
		# If still a start_point, set the final point of the curve to the child hook position
		if (is_start_point):
			childCurve.get_child(3).global_position = child_hook.global_position;
		else: 
			childCurve.drawing_curve = false;
		

func _check_origin(origin):
	# Check to see if the mouse is within the center of the hook
	if ((get_global_mouse_position()- center).length_squared() > r): return
	# Check to see if the origin is itself or part of the same group of hooks, in which case dgaf
	if (origin.get_parent() == get_parent()): return
	# Check to make sure arrows are on same side
	if (sign(radius) * sign(origin.radius) < 0): return
	# Check to make sure the hook is connecting a sentence & rule
	if _get_attached().charge * origin._get_attached().charge == 1: return 
	# Turn the origin into a starting hook, itself into a end hook
	origin._turn_to_start(self);
	_turn_to_end(origin);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update the center of the hook
	center = global_position;
	_set_points();
	
	
# Position the points to draw the curve accurately.
func _set_points():
	# Don't bother if the curve isn't being rendered
	if childCurve.drawing_curve == false: return
	# Get the vector from the center to the mouse
	var del = get_global_mouse_position()- center; 
	# Set the first point on the curve to the hook itself
	childCurve.get_child(0).global_position = center;
	if (is_start_point):
		# If the curve is a start point, make the last point stay at the child_hook
		childCurve.get_child(3).global_position = child_hook.global_position;
	else:
		# Otherwise, make the last point the position of the mouse
		childCurve.get_child(3).global_position = get_global_mouse_position();
	# Calculate good radius, a value that ensures that whether P0 is to the left or right of P3
	# P1 & P2 are at most radius away from a hook
	var good_radius = sign(radius) * (abs(radius) + max(sign(radius) * (childCurve.get_child(3).position.x - childCurve.get_child(0).position.x), 0));
	# Set the second point on the curve to be on the same horizontal as the first,
	# But a distance of radius away. Note radius can & should be signed
	childCurve.get_child(1).global_position = center + Vector2(good_radius, 0);
	
	# Set the 3rd point to form a right angle between the second point & last point
	childCurve.get_child(2).global_position = Vector2(childCurve.get_child(1).global_position.x, childCurve.get_child(3).global_position.y);
	childCurve.get_child(1).global_position = (childCurve.get_child(2).global_position + childCurve.get_child(1).global_position)/2 ;
	
func _get_attached():
	return get_parent().get_parent();

# Set the 4 "condition" variables of the hook accordingly
func _turn_to_end(origin):
	if (is_start_point): child_hook._turn_to_none()
	if (is_end_point): origin_hook._turn_to_none();
	is_end_point = true;
	is_start_point = false;
	child_hook = null;
	origin_hook = origin;
	childCurve.drawing_curve = false;
	hide();
	
func _turn_to_start(child):
	if (is_end_point): origin_hook._turn_to_none()
	is_start_point = true;
	is_end_point = false;
	child_hook = child;
	origin_hook = null;
	show();
	
func _turn_to_none(draw = false):
	if (is_start_point):
		is_start_point = false;
		child_hook._turn_to_none();
	if (is_end_point):
		is_end_point = false;
		origin_hook._turn_to_none();
	child_hook = null;
	origin_hook = null;
	childCurve.drawing_curve = draw;
	show();
