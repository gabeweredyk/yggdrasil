extends Rule
class_name BionditionalIntro

func _init():
	ruleName = "% Intro";
	inSenNum = 0;
	outSenNum = 1;
	inBranchNum = 2;

func _check_validity():
	if not _check_numbers(): return false;
	var sens = _deoperate(outSentences[0], "%");
	# Check to make sure out sentence has an antecedent & conclusion
	if (len(sens) != 2): return false;
	var p = sens[0];
	var q = sens[1];
	# Check to make sure ASsumptions of the branch are exclusively p
	var assumptions = inBranches[0][0] + inBranches[1][0];
	if assumptions == [p, q]:
		return q in inBranches[0][1] and p in inBranches[1][1];
	elif assumptions == [q, p]:
		return p in inBranches[0][1] and q in inBranches[1][1];
	else: 
		return false;
