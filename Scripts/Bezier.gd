class_name Bezier
extends Node2D

# Store the Curve2D data structure
var curve : Curve2D;

# Is true when the curve should be rendered
var drawing_curve = false;
var active = false;

func _ready():
	# Instantiate curve
	add_to_group("Bezier");
	curve = Curve2D.new();
	_update_curve();
	
# Called whenever the curve needs to adjust according to P0-P3 positions
func _update_curve():
	curve = Curve2D.new();
	var p0_in = Vector2.ZERO;
	var p0_vertex = $P0.position;
	var p0_out = $P1.position - $P0.position;
	var p1_in = $P2.position - $P3.position;
	var p1_vertex = $P3.position;
	var p1_out = Vector2.ZERO;
	curve.add_point(p0_vertex, p0_in, p0_out);
	curve.add_point(p1_vertex, p1_in, p1_out);
	
	
func _process(_delta):
	_update_curve();
	# Draws the curve according to the appropriate boolean.
	$P0.visible = drawing_curve;
	$P3.visible = drawing_curve;
	queue_redraw();
	
	
func _draw():
	# return appropriately
	if (not drawing_curve): return;
	# Get intermediate points in the curve
	var curve_points = curve.get_baked_points();
	# Draw a straight line between each point in curve_points
	for i in len(curve_points)-1:
		draw_line(curve_points[i], curve_points[i + 1], Color(1,1,1,1),0.5, true);
	# Rotate the arrowhead accordingly
	$P3.global_rotation = ($P3.position - $P2.position).angle();
	# Debugging feature to draw P1 & P2
	#draw_circle($P0.position, 5, Color.LAWN_GREEN); draw_circle($P1.position, 5, Color.LAWN_GREEN); draw_circle($P2.position, 5, Color.LAWN_GREEN); draw_circle($P3.position, 5, Color.LAWN_GREEN);

# Position the points to draw the curve accurately.
func _set_points(radius:float, x0:Vector2, x1:Vector2):
	# Don't bother if the curve isn't being rendered
	if drawing_curve == false: return
	# Set the first point on the curve to the hook itself
	$P0.global_position = x0;
	$P3.global_position = x1;
	# Calculate good radius, a value that ensures that whether P0 is to the left or right of P3
	# P1 & P2 are at most radius away from a hook
	var good_radius = sign(radius) * (abs(radius) + max(sign(radius) * (x1.x - x0.x), 0));
	# Set the second point on the curve to be on the same horizontal as the first,
	# But a distance of radius away. Note radius can & should be signed
	$P1.global_position = x0 + Vector2(good_radius, 0);
	
	# Set the 3rd point to form a right angle between the second point & last point
	$P2.global_position = Vector2($P1.global_position.x, $P3.global_position.y);
	#$P1.global_position = ($P2.global_position + $P1.global_position)/2 ;
