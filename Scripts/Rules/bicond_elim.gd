extends Rule
class_name BiconditionalElim

func _init():
	ruleName = "% Elim";
	inSenNum = 2;
	outSenNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	# Split in1 & in2 by →
	var in1 = _deoperate(inSentences[0], "%");
	var in2 = _deoperate(inSentences[1], "%");
	# Get the larger list
	var inLonger;
	var inShorter
	if (len(in1) >= len(in2)): 
		inLonger = in1;
		inShorter = in2;
	else:
		inShorter = in1;
		inLonger = in2;

	inShorter.append(outSentences[0]);
	
	# Make sure the conclusion agrees with the out sentence
	return _is_subset(inShorter, in1)
