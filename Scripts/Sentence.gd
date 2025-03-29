# Script to be attached to Sentences
class_name Sentence
extends BranchItem

# Variable to hold to regex parsing
var regex : RegEx;

# Variable to check whether or not the text is a WFF (useful for interacting with rules)
var WFF : bool;

# Called when the node enters the scene tree for the first time.
func _ready():
	# From parents
	curveRadius = 50;
	_standard_ready();
	charge = 0;
	# Instantiate the regex to the string made to match WFFs
	# Link to Regex101 posting: https://regex101.com/r/vq9mPz/1
	regex = RegEx.new()
	regex.compile(r'^(?P<WFF>(?P<L>~*(?>[A-Z\^!]|\(\g<WFF>\)))(?(?=\$)\$\g<L>|(?:(?P<O>[\*%&|])(?:\g<L>\k<O>)*\g<L>)?))$');
	add_to_group("SaveableData");
	_on_text_change($PanelContainer/MarginContainer/LineEdit.text);
	pass 

# Override _select from parent class
func _select():
	$PanelContainer/MarginContainer/LineEdit.grab_focus();

# Signal that gets called when text is updated, checks regex parsing
func _on_text_change(text:String):
	# Strip whitespace of text
	text = text.replace(' ', '');
	# Try to match the string with regex
	var rmatch = regex.search(text);
	# Update WFF accordingly
	WFF = rmatch or text == "";
	# If sucessful, make background white, else make red
	if (WFF):
		$PanelContainer/ColorRect.color = Color.WHITE;
	else:
		$PanelContainer/ColorRect.color = Color.INDIAN_RED;
		

# Getters & setters
func _get_text():
	if not WFF: return "";
	var text = $PanelContainer/MarginContainer/LineEdit.text;
	text = text.replace(' ', '');
	return text;
	
func _get_raw_text():
	return $PanelContainer/MarginContainer/LineEdit.text;
	
func _set_text(text:String):
	$PanelContainer/MarginContainer/LineEdit.text = text;
	
func save():
	var assumed = false;
	for i in LeftCircles.get_children(): assumed = i.assumed or assumed;
	
	var to : Array;
	for i in (LeftCircles.get_children() + RightCircles.get_children()):
		if not i.is_start_point: continue
		to.append( str(i.child_hook._get_attached().get_path()).replace("@","_") );
		
	
	var save_dict = {
		"type" : "Sentence",
		"name" : name.replace("@","_"),
		"parent" : str(get_parent().get_path()).replace("@","_"),
		"text" : _get_raw_text(),
		"inBranch" : get_parent().is_in_group("BranchBox"),
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"index" : get_index(),
		"assumed" : assumed,
		"to" : to
	}
	
	return save_dict;
	
