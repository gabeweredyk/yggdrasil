extends Rule
class_name ContradictionIntro

func _init():
	ruleName = "^ Intro";
	inSenNum = 2;
	outSenNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	# Make sure a ⊥ is being returned
	if not (outSentences[0] == "^"): return false;
	# Make sure an empty sentence isn't being passed through
	if ("" in inSentences): return false;
	# Check to see if the start of one of the sentences start with ¬ and when stripped of its first character is equal to the other sentence
	return inSentences[0] == _negate(inSentences[1]) or inSentences[1] == _negate(inSentences[0]) 
