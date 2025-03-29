class_name Draggable
extends Control

# dragging is true when the sentence is being dragged
var dragging = false;
# offset is a vector used to make sure the sentence doesnt jump around after being selected
var offset = Vector2();

var highlight = false;
var highlightBox : Object;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add to appropriate groups
	add_to_group("Clickable");
	add_to_group("Draggable");
	pass 

# Called when the position needs to be updated accordingly
func _drag():
	highlightBox.visible = highlight;
	# dont do shit if already dragging
	if (not dragging): return
	# follow mouse
	global_position = get_global_mouse_position() - offset;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_drag()

func _input(event):
	#Don't bother checking for inputs if not being dragged
	if (not dragging): return;
	# If mouse released, call the dropped function
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		# Setting dragging to false
		dragging = false;
		# Call a _dropped function. Use varies by child
		_dropped();
		
# Template for dropping
func _dropped():
	pass
		
# update the offset vector
func _update_offset():
	offset = get_global_mouse_position() - global_position;
