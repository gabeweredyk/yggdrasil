extends Rule
class_name AndIntro

func _init():
	ruleName = "& Intro"
	# Only one sentence can be deduced from ∧ intro
	outSenNum = 1;

func _check_validity():
	if not _check_numbers(): return false;
	# Get the deduced sentence
	var sen = outSentences[0];
	# Get the individual sentenecs that have been conjuncted in sen
	var outConjunctedSentences = _deoperate(sen, "&");
	# Store all the conjuncted sentences that have came in
	var inConjunctedSentences : Array[String];
	# Loop over all supporting sentences
	for ins in inSentences:
		# Get the individual conjuncted sentences from each supporting sentence
		var temp = _deoperate(ins, "&");
		# and add it to inConjuncted Sentence
		inConjunctedSentences += temp;
	# Check to make sure that inConjunctedSentences & outConjunctedSentences are subsets of each other, implying they're equal
	return _is_subset(inConjunctedSentences, outConjunctedSentences) and _is_subset(outConjunctedSentences, inConjunctedSentences);
