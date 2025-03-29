extends Rule
class_name AlphaDecomposition

var d = Decomposition.new();

func _init():
	ruleName = "α"
	# Alpha can only deduce from 1 sentence
	inSenNum = 1;

func _check_validity():
	# See Parent Class
	if not _check_numbers(): return false;
	# Get the single in sentence
	var sen = inSentences[0];
	# Get the alpha decomposoition
	var alpha = d._alpha_decompose(sen);
	
	return _equal_sets(outSentences,alpha);

