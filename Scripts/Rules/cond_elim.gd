extends Rule
class_name ModusPonens

func _init():
	ruleName = "$ Elim";
	inSenNum = 2;
	outSenNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	# Split in1 & in2 by →
	var in1 = _deoperate(inSentences[0], "$");
	var in2 = _deoperate(inSentences[1], "$");
	# Check to see if one of the earlier sentences was innapropriately split
	# Consider the case "(P→Q)→R, P→Q"
	if inSentences[1] in in1: in2 = [inSentences[1]];
	if inSentences[0] in in2: in1 = [inSentences[0]];
	# If sentences don't decompose into two sentences & one sentence respectively, break
	if (len(in1) * len(in2) != 2): return false
	# Get the antecedent, has to be the first entry either way
	var p = in1[0];
	if (in2[0] != p): return false
	# Get the conclusion from the in sentences
	var q;
	if (len(in1) == 2): q = in1[1];
	else: q = in2[1];
	# Make sure the conclusion agrees with the out sentence
	return q == outSentences[0];
