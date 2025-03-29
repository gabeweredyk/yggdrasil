extends Rule
class_name ConditionalIntro

func _init():
	ruleName = "$ Intro";
	inSenNum = 0;
	outSenNum = 1;
	inBranchNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	var sens = _deoperate(outSentences[0], "$");
	# Check to make sure out sentence has an antecedent & conclusion
	if (len(sens) != 2): return false;
	var p = sens[0];
	var q = sens[1];
	# Check to make sure ASsumptions of the branch are exclusively p
	if (inBranches[0][0] != [p]): return false;
	# Check to make sure q is in the branch
	return q in inBranches[0][1];
