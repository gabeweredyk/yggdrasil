extends Rule
class_name OrIntro

func _init():
	ruleName = "| Intro";
	inSenNum = 1;

func _check_validity():
	if not _check_numbers(): return false
	# Get disjuncted sentences going in
	var inDisjunctedSentences = _deoperate(inSentences[0], "|");
	# Check all the deductions
	for out in outSentences:
		# Get the disjuncted sentences in out
		var outDisjunctedSentences = _deoperate(out, "|");
		# Make sure that inDisjunctedSentences is a subset of outDisjunctedSentences
		if not _is_subset(inDisjunctedSentences, outDisjunctedSentences): return false
	return true
