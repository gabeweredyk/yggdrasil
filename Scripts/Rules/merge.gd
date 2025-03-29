extends Rule
class_name Merge

func _init():
	ruleName = "Merge";
	inSenNum = 0;
	outSenNum = -1;
	inBranchNum = -1;

func _check_validity():
	if not _check_numbers(): return false;
	
	for out in outSentences:
		for branch in inBranches:
			if out not in branch[1] and "^" not in branch[1]: return false
	
	return true
	
