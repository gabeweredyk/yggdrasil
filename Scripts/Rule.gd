class_name Rule
extends BranchItem

# Arrays for storing the sentences that go in & out of a rule
var inSentences : Array[String];
var outSentences : Array[String];

# Arrays for storing the branches that go in & out of rules
# Branches are stored as [assumed sentences, all sentences]
var inBranches : Array;
var outBranches : Array;
# Comes up often enough to allocate memory to the set of all assumptions in each branch coming in/out
var outAssumptions = [];
var inAssumptions  = [];


# Variable to store the rule name, varies depending on subclass
var ruleName = "";

# Variables to specify how much should be going into each rule
# If -1, simply ask for at least 1 of it
var inSenNum = -1;
var outSenNum = -1;
var inBranchNum = 0;
var outBranchNum = 0;

# Is the rule applied validly?
var valid = false;

var saveManager;


func _ready():
	# Set charge to -1 (sentences have charge 1)
	charge = -1;
	add_to_group("SaveableData");
	# Update the label with the rule name
	$PanelContainer/Label.text = ruleName;
	saveManager = get_node("/root/Workspace/CanvasLayer/Control/File");
	# From parent. "Why not use _init()?" just doesn't work sorry
	_standard_ready();
	
	
func _process(delta):
	# From parent
	_drag();
	# Move the anchors for the arrows between sentences & inference rules
	_position_circles();
	# Process incoming sentences
	_get_sentences();
	# Check the validity of the rule
	valid = _check_validity();
	if (valid):
		$PanelContainer/ColorRect.color = Color(0, 0, 0, 0.35);
	else:
		$PanelContainer/ColorRect.color = Color(1, 0, 0, 0.35);
	
# Sentences for updating the arrays inSentences, outSentences, inBranches, outBranches
func _get_sentences():
	# Empty arrays
	inSentences = [];
	outSentences = [];
	inBranches = [];
	outBranches = [];
	inAssumptions = [];
	outAssumptions = [];

	if saveManager.busy: return

	# Loop over all hooks attahced to the rule
	for hook in $LeftCircles.get_children() + $RightCircles.get_children():
		# Only care if hook is a start or end point
		if hook.is_start_point:
			# If connected to a branch, update outBranches
			if hook.child_hook == null: continue
			elif hook.child_hook._get_attached().charge == 1:
				var branch = hook.child_hook._get_attached()._get_branch();
				outBranches.append(branch);
			# Otherwise, add to outSentences
			else:
				var sen = hook.child_hook._get_attached()._get_text();
				if sen == null: continue
				outSentences.append(_strip_parenthesis(sen));
		elif hook.is_end_point:
			# If connected to a branch, update inBranches
			if hook.origin_hook == null: continue
			elif hook.origin_hook._get_attached().charge == 1:
				var branch = hook.origin_hook._get_attached()._get_branch();
				inBranches.append(branch);
			# Otherwise, add to inSentences
			else:
				var sen = hook.origin_hook._get_attached()._get_text();
				if sen == null: continue
				inSentences.append(_strip_parenthesis(sen));
	
	for i in inBranches:
		inAssumptions.append(i[0])
		inAssumptions[-1].sort()
	for i in outBranches:
		outAssumptions.append(i[0])
		outAssumptions[-1].sort()

# Meant to be changed by each child, consists of the rules definition pretty much
func _check_validity():
	return _check_numbers();
	
func _check_numbers():
	return \
	(len(inSentences) == inSenNum or (inSenNum == -1) and len(inSentences) != 0 ) and \
	(len(outSentences) == outSenNum or (outSenNum == -1) and len(outSentences) != 0 ) and \
	(len(inBranches) == inBranchNum or (inBranchNum == -1) and len(inBranches) != 0 ) and \
	(len(outBranches) == outBranchNum or (outBranchNum == -1) and len(outBranches) != 0 );
	
# O(n) algorithm for getting sentences that are seperated by a certain operator
# Given that the inSentences & outSentences are WFFs, this algorithm is better than any Regex thing I can think of
func _deoperate(str:String,op:String,recurse = 0):
	if (recurse > 1): 
		var temp : Array[String] = [str];
		return temp;
	# Count what "level" or parenthesis the string is in
	var parenthesisCount = 0;
	# Store the statements
	var statements : Array[String] = [""];
	for i in str:
		# IF operator is encountered & at base level, start storing a new string
		if i == op and parenthesisCount == 0: 
			var temp = statements[-1];
			statements.pop_back();
			statements += _deoperate(temp, op, 2*recurse);
			statements.append("");
		# Adjust parenthesisCount appropriately
		elif i == "(": parenthesisCount += 1;
		elif i == ")": parenthesisCount -= 1;
		# If the current character isn't the operator or (), then add to the current string
		else: statements[-1] += i;
		#
	if (op in statements[-1]):
		var temp = statements[-1];
		statements.pop_back();
		statements += _deoperate(temp, op, 2*recurse);
	# Return the array
	return statements;

# Get rid of parenthesis around sentence if they exist
func _strip_parenthesis(text:String):
	if (text == "" or text[0] != "(" or text[-1] != ")"): return text
	text = text.substr(1,len(text) - 2)
	return text;
	
func _is_subset(P:Array,Q:Array):
	for i in P:
		if i not in Q: return false
	return true
	
func _equal_sets(P:Array,Q:Array):
	return (len(P) == len(Q) and _is_subset(P,Q) and _is_subset(Q,P));
	
	
func _is_subset_of_sets(P:Array,Q:Array):
	for p in P:
		var hit = false;
		for q in Q:
			if _equal_sets(p,q): 
				hit = true;
				break
		if not hit: return false;
	return true;
	
func _equal_sets_of_sets(P:Array,Q:Array):
	return (len(P) == len(Q) and _is_subset_of_sets(P,Q) and _is_subset_of_sets(Q,P));
	
func _negate(text:String):
	for i in "$%^&*|":
		if i in text: return "~(" + text + ")";
	return "~" + text;
	
func save():
	var assumed = false;
	for i in LeftCircles.get_children(): assumed = i.assumed or assumed;
	
	var to : Array;
	for i in (LeftCircles.get_children() + RightCircles.get_children()):
		if not i.is_start_point: continue
		to.append( str(i.child_hook._get_attached().get_path()).replace("@","_") );
		
	var save_dict = {
		"type" : "Rule",
		"name" : name.replace("@","_"),
		"parent" : str(get_parent().get_path()).replace("@","_"),
		"rule" : get_script().get_path(),
		"inBranch" : get_parent().is_in_group("BranchBox"),
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"index" : get_index(),
		"assumed" : assumed,
		"to" : to
	}
	
	return save_dict;
