extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time ince the previous frame.
func _process(delta):
	pass

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_OBJECT
	
func _drop_data(at_position, data):
	data._stop_Dragging()
