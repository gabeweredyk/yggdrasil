extends Rule
class_name OrElim

func _init():
	ruleName = "| Elim";
	inSenNum = 1;
	outSenNum = -1;
	inBranchNum = -1;

func _check_validity():
	if not _check_numbers(): return false;
	var inDisjunctedSentences = _deoperate(inSentences[0], "|");
	
	var branchStarts = [];
	for i in inBranches:
		branchStarts += i[0];
		
	if not _equal_sets(branchStarts, inDisjunctedSentences): return false
		
	for out in outSentences:
		for branch in inBranches:
			if out not in branch[1]: return false
	
	return true
	
