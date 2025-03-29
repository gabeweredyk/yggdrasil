extends Rule

func _init():
	ruleName = "~ Elim";
	inSenNum = 1;
	outSenNum = 1;
	
func _check_validity():
	if not _check_numbers(): return false;
	# Make sure there are more than two characters in the in sentence
	if (len(inSentences[0]) <= 2): return false
	# Get the in sentence without the first two characters
	var sen = _strip_parenthesis(inSentences[0].substr(2));
	# Return true if sen is then the out sentence
	return sen == outSentences[0];
