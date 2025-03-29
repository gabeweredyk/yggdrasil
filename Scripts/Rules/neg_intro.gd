extends Rule
class_name NegationIntro

func _init():
	ruleName = "~ Intro";
	inSenNum = 0;
	outSenNum = 1;
	inBranchNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	# Make sure conclusion has a negation
	if outSentences[0] == "" or outSentences[0][0] != "~": return false;
	# get the negation of p
	var p = _strip_parenthesis(outSentences[0].substr(1));
	# Check to make sure Assumptions of the branch are exclusively p
	if (inBranches[0][0] != [p]): return false;
	# Check to make sure branch leads to a contradiction
	return "^" in inBranches[0][1];
