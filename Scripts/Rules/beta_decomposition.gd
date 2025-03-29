extends Rule
class_name BetaDecomposition

var d = Decomposition.new();

func _init():
	ruleName = "β"
	# Alpha can only deduce from 1 sentence
	inSenNum = 1;
	outSenNum = 0;
	outBranchNum = -1;

func _check_validity():
	# See Parent Class
	if not _check_numbers(): return false;
	# Get the single in sentence
	var sen = inSentences[0];
	# Get the alpha decomposoition
	var beta = d._beta_decompose(sen);
	var assumptions = []
	for i in outBranches:
		assumptions.append(i[0]);
		assumptions[-1].sort();
		
	return _equal_sets_of_sets(beta, assumptions);
