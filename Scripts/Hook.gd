# Script for anchors that connect rules & sentences
class_name Hook
extends Sprite2D

# Store the center of the hook
var center = Vector2(0, 0);

# Preload the bezier curve node
var bezier = preload("res://Nodes/bezier.tscn");

# Store the child curve
var childCurve : Object;

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

# Boolean for whether or not the hook is "assumed to be satisfied"
var assumed = false;

# Boolean for whether the hook is properly used up so to speal
var satisfied = false;

# The desired distance the curvev sticks out
@export var radius : float;

var d = Decomposition.new();

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
			
		if (Input.is_key_pressed(KEY_CTRL)):
			assumed = not assumed;
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
	if _get_attached().charge == origin._get_attached().charge: return 
	# Turn the origin into a starting hook, itself into a end hook
	origin._turn_to_start(self);
	_turn_to_end(origin);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update the center of the hook
	center = global_position;
	var x1 = get_global_mouse_position();
	if (is_start_point and child_hook != null): x1 = child_hook.global_position;
	childCurve._set_points(radius, center, x1);
	
	_indicate_status();
	
func _indicate_status():
	satisfied = assumed;
	if (_get_attached().charge == -1):
		satisfied = _get_attached().valid;
	elif is_end_point and _get_attached().charge == 0:
		satisfied = origin_hook.satisfied;
	elif is_start_point and _get_attached().charge == 0 and child_hook._get_attached().charge == -1:
		var sensA = d._alpha_decompose(_get_attached()._get_text());
		satisfied = _equal_sets(sensA, child_hook._get_attached().outSentences);
		
		var sensB = d._beta_decompose(_get_attached()._get_text());
		satisfied = satisfied or _equal_sets(sensB, child_hook._get_attached().outAssumptions)
		
	elif not is_end_point and not is_start_point and _get_attached().charge == 0:
		satisfied = _get_attached().WFF and len(_get_attached()._get_text()) <= 2 and get_parent().name == "RightCircles"
	else:
		satisfied = false;
		
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
	
func _is_subset(P:Array,Q:Array):
	for i in P:
		if i not in Q: return false
	return true

func _equal_sets(P:Array,Q:Array):
	return (len(P) == len(Q) and _is_subset(P,Q) and _is_subset(Q,P));
