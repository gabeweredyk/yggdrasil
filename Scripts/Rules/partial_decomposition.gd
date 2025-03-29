extends Rule
class_name PartialDecomposition

var d = Decomposition.new();

func _init():
	ruleName = "∂";

func _check_validity():
	# See Parent Class
	if (len(inSentences) != 1 or len(inBranches) != 0): return false;
	if (len(outSentences) * len(outBranches) != 0): return false;
	
	# Get the single in sentence
	var sen = inSentences[0];
	
	var decomp = [];
	var comparingList = [];
	if (len(outSentences) != 0):
		decomp = d._alpha_decompose(sen);
		comparingList = outSentences;
	else: 
		decomp = d._beta_decompose(sen);
		for i in outBranches:
			comparingList.append(i[0]);
			comparingList[-1].sort();

	if len(decomp) == 0: return false;
	match typeof(decomp[0]):
		TYPE_STRING: return _is_subset(comparingList,decomp);
		TYPE_ARRAY: return _is_subset_of_sets(comparingList,decomp);
