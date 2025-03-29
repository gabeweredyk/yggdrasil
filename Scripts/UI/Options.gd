extends PopupMenu

var ruleDictionary;
var keypad;
var goals;

func _ready():
	ruleDictionary = get_node("/root/Workspace/CanvasLayer/Rule Dictionary")
	ruleDictionary.hide();
	keypad = get_node("/root/Workspace/CanvasLayer/Keypad")
	keypad.hide();
	goals = get_node("/root/Workspace/CanvasLayer/Goals")
	goals.hide();


func _on_id_pressed(id):
	match id:
		0: ruleDictionary.visible = not ruleDictionary.visible
		1: keypad.visible = not keypad.visible
		2: goals.visible = not goals.visible
	set_item_checked(id, not is_item_checked(id))
