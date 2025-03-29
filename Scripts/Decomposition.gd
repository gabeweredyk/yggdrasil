class_name Decomposition

# Decompositions for propositional calculus tableaux
# See https://en.wikipedia.org/wiki/Method_of_analytic_tableaux
var operators = "~$%&|"
var op = "";

# Decompose a sentence by Alpha-Decomposition
func _alpha_decompose(sen:String):
	if (sen == ""): return []
	if len(sen) == 1: return [sen]
	var demorganed = false;
	op = _get_main_operator(sen);
	var ogSen = sen;
	while op == "~" and sen[1] != "~":
		demorganed = not demorganed;
		sen = _strip_parenthesis(sen.substr(1));
		op = _get_main_operator(sen);
	var sens = _deoperate(sen,op,1);
	if op == "~":
		return [_strip_parenthesis(sen.substr(2))]
	if op == "&":
		if demorganed:
			return [ogSen]
		else:
			return sens
	elif op == "|":
		if demorganed:
			var negatedSens = []
			for i in sens:
				negatedSens.append(_negate(i))
			return negatedSens
		else:
			return [ogSen]
	elif op == "$":
		if demorganed:
			return [sens[0], "~" + sens[1]]
		else:
			return [ogSen]
	elif op == "%":
		if demorganed:
			return [ogSen]
		else:
			var impliedSens = [sens[-1] + "$" + sens[0]];
			for i in range(len(sens) - 1):
				impliedSens.append(sens[0] + "$" + sens[1]);
			return impliedSens
			
# Decompose a sentence by Alpha-Decomposition
func _beta_decompose(sen:String):
	if (sen == ""): return []
	if len(sen) == 1: return [sen]
	var demorganed = false;
	op = _get_main_operator(sen);
	var ogSen = sen;
	while op == "~" and sen[1] != "~":
		demorganed = not demorganed;
		sen = _strip_parenthesis(sen.substr(1));
		op = _get_main_operator(sen);
	var sens = _deoperate(sen,op,1);
	if op == "~":
		return [[_strip_parenthesis(sen.substr(2))]]
	if op == "&":
		if demorganed:
			var negatedSens = []
			for i in sens:
				negatedSens.append(["~" + i])
			return negatedSens
		else:
			return [[ogSen]]
	elif op == "|":
		if demorganed:
			return [[ogSen]]
		else:
			var branchSens = [];
			for i in sens:
				branchSens.append([i]);
			return branchSens
	elif op == "$":
		if demorganed or (len(sens) != 2):
			return [[ogSen]]
		else:
			return [[_negate(sens[0])], [sens[1]]]
	elif op == "%":
		if demorganed:
			return [[_negate(sens[1]), sens[0]], [_negate(sens[0]), sens[1]]] 
		else:
			var negatedSens = []
			for i in sens:
				negatedSens.append(_negate(i))
			negatedSens.sort();
			return [sens, negatedSens];
			
		
func iff(p:bool,q:bool):
	return  bool(~(int(p) ^ int(q)))


# Get the "main operator" of a sentence, or the "final" operator
# E.g.: The sentence (P→Q)∧(Q↔R) has a main operator of &
func _get_main_operator(sen:String):
	var parenthesisCount = 0;
	var maxLevel = 9223372036854775807;
	var op = null;
	for i in sen:
		if i == "(": parenthesisCount += 1;
		elif i == ")": parenthesisCount -= 1;
		elif i in "$%&|":
			if parenthesisCount > maxLevel: continue
			op = i;
			maxLevel = parenthesisCount;
		elif i == "~" and op == null:
			op = "~"
			maxLevel = parenthesisCount;
	if op == null: return "&"
	return op;
	
# Stolen from Rule class
# O(n) algorithm for getting sentences that are seperated by a certain operator
# Given that the inSentences & outSentences are WFFs, this algorithm is better than any Regex thing I can think of
func _deoperate(str:String,op:String,recurse = 0):
	if (recurse > 1): 
		var temp : Array[String] = [str];
		return temp;
	# Count what "level" or parenthesis the string is in
	var parenthesisCount = 0;
	# Store the statements
	var statements : Array[String] = [""];
	for i in str:
		# IF operator is encountered & at base level, start storing a new string
		if i == op and parenthesisCount == 0: 
			var temp = statements[-1];
			statements.pop_back();
			statements += _deoperate(temp, op, 2*recurse);
			statements.append("");
		# Adjust parenthesisCount appropriately
		elif i == "(": parenthesisCount += 1;
		elif i == ")": parenthesisCount -= 1;
		# If the current character isn't the operator or (), then add to the current string
		else: statements[-1] += i;
		#
	if (op in statements[-1]):
		var temp = statements[-1];
		statements.pop_back();
		statements += _deoperate(temp, op, 2*recurse);
	# Return the array
	return statements;
	
	
# Stolen from rule class
func _strip_parenthesis(text:String):
	if (text == "" or text[0] != "(" or text[-1] != ")"): return text
	text = text.substr(1,len(text) - 2)
	return text;
	
func _negate(text:String):
	for i in "$%^&*|":
		if i in text: return "~(" + text + ")";
	return "~" + text;
