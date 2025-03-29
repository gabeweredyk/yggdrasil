extends HBoxContainer

var inputHandler;

func _ready():
	inputHandler = get_node("/root/Workspace/InputHandler");

func _button_pressed(op:String):
	print("Step 1")
	if inputHandler.last_selected == null: return
	print("Step 2")
	if inputHandler.last_selected.charge != 0: return
	print("Step 3")
	print(inputHandler.last_selected)
	inputHandler.last_selected._set_text(inputHandler.last_selected._get_raw_text() + op);
	
