extends Rule
class_name AndElim

func _init():
	ruleName = "& Elim"
	# ∧ Elim can only deduce from 1 sentence
	inSenNum = 1;

func _check_validity():
	# See Parent Class
	if not _check_numbers(): return false;
	# Get the single in sentence
	var sen = inSentences[0];
	# Get the individually conjuncted sentences in sen
	var inConjunctedSentences = _deoperate(sen, "&");
	# Check every deducted sentence
	for out in outSentences:
		# Get all the conjuncted sentences from out
		var outConjunctedSentences = _deoperate(out, "&");
		# check to make sure all of those sentences come from original sentence
		if not _is_subset(outConjunctedSentences, inConjunctedSentences): return false
	return true
