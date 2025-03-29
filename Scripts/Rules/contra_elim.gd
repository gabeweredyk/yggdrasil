extends Rule
class_name ContradictionElim

func _init():
	ruleName = "^ Elim";
	inSenNum = 1;

# Come on do I even need to leave a comment here
func _check_validity():
	if not _check_numbers(): return false;
	return inSentences[0] == "^";
