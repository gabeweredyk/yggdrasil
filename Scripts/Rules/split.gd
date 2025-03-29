extends Rule
class_name Split

func _init():
	ruleName = "Split";
	inSenNum = 0;
	outSenNum = 0;
	outBranchNum = 2;

func _check_validity():
	if not _check_numbers(): return false;
	
	if (len(outBranches[0][0]) * len(outBranches[1][0]) != 1 ): return false;
	
	var p = outBranches[0][0][0];
	var q = outBranches[1][0][0];
	
	return (p == _negate(q)) or (q == _negate(p));
	
