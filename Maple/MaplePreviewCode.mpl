# This *.mpl file generates the maple_preview_code_X_X_X.mla and MapleCustomPreviewer.mla files.
# The former is the custom library used for previewing student Maple outputs in Möbius.
# The latter is an identical library without version number in the file name, called in TestingThePreviewer.mpl for quick sanity checks.

# These libraries both contain:
# - common_function_names, common_operators, common_regex_literal_operators (lists of strings used as global variables),
# - MaplePreviewerVersion (proc: outputs current version number),
# - displayMapleVersionNumber (proc: concatenates HTML postscript with version number and contact details),
# - create_MathML (proc: generates MathML from (most) parsable student inputs as literally as possible),
# - add_semantic_advice (proc: concatenates HTML advice for parsable student inputs),
# - add_syntax_advice (proc: concatenates HTML advice for non-parsable student inputs),
# - testmyexpression (proc: generates HTML message for previewer based on student input).

# Instructions for Windows:
# Run this file with make.bat (a batch script file which should accompany this file):
# (1) Open the terminal.
# (2) Navigate to the directory containing this file, make.bat and TestingThePreviewer.mpl.
# (3) In the command line, type ".\make" (without "") to run make.bat (deletes any old *.mla files and runs both *.mla files with cmaple).
# Note: In Windows, running Maple from the command line requires adding Maple to the PATH.

## The version number is updated manually below:

MaplePreviewerVersion := proc() return "1.0.5" end proc;

#####################################################################
#                                                                   #
#####################################################################

# This proc appends the previewer version number, and contact details of the staff member responsible for fielding errors,
# to the end of the string fed to the previewer. Called at the end of message generation.

displayMapleVersionNumber:=proc(inputString) local VersionNumber,versionMessage;
    VersionNumber:=MaplePreviewerVersion():
    versionMessage:=sprintf("<p style=\"text-align: right;color: #12b0fd;\" title=\"Contact Joshua Capel (j.capel@unsw.edu.au) to report errors.\">UNSW M&ouml;bius Custom Previewer v%s</p>",VersionNumber):

    return cat(inputString,versionMessage):
end proc;

#####################################################################
#                                                                   #
#####################################################################

# Sets several useful lists as global variables:

common_function_names :=
    [   "exp",  "ln",   "log",  "abs",  "sqrt"
    ,   "int",  "diff", "Int",  "Diff", "integrate", "Integrate", "sum"
    ,   "sin" ,   "cos" ,   "tan" ,   "cot" ,"sec"
    ,   "sinh",  "cosh" ,   "tanh",   "coth","sech"
    ,"arcsin" ,"arccos" ,"arctan" ,"arccot" ,"arcsec"
    ,"arcsinh","arccosh","arctanh","arccoth","arcsech"];

common_operators := ["*","-","+","*","^"];

common_regex_literal_operators := ["\\*","\\+","-","\\^"];

forbidden_symbols := {"{","}","[","]"};

#####################################################################
#                                                                   #
#####################################################################

# The following proc takes a student's input string and creates MathML based on the input.
# This is the MathML that is previewed with the student's input string in the previewer.
# The intention is to be as literal as possible; functions in the native Maple `MathML` package take (parsed) Maple expressions, not strings, and may conduct unwanted calculations on student inputs before displaying.

create_MathML:=proc(EXPRESSION) local Message,newEXPRESSION,func_list,funcname,opname,RESPONSE,mfenced_pattern_to_replace; global common_function_names,common_operators;

    ## 0. Initialise `Message` as empty string; this will be returned the output of `create_MathML` at the end.
    Message := "":

    ## 1. Capture input (`EXPRESSION`) in a list (to be fixed before returning).
    newEXPRESSION:=cat("[",EXPRESSION,"]");
    
    ## 2. Add markers to key features of the input string (escapes unintended evaluations later, adding robustness to inert form):
    ## (Numerics and functions escaped separately.)

    ## a. Escape numerics:
    # (Does not trigger if `Matrix` or `Vector` expressions detected, to avoid escaping indices or dimensions).
    # - If "." detected after numeric, replace with "DECIMALDOT".
    # - If numeric detected, concatenate "NUMBER" with numeric.
    # - If letter precedes added "NUMBER", remove "NUMBER" (numeric in variables left alone, numeric after "DECIMALDOT" not treated as separate).
    if evalb(max(StringTools:-Search(["Matrix","Vector"],newEXPRESSION))=0) then
        newEXPRESSION:=StringTools[RegSubs]("([0-9]+)\\."="\\1DECIMALDOT",newEXPRESSION);
        newEXPRESSION:=StringTools[RegSubs]("([0-9]+)"="NUMBER\\1",newEXPRESSION);
        newEXPRESSION:=StringTools[RegSubs]("([a-zA-Z])NUMBER"="\\1",newEXPRESSION)
    end if;
    
    ## b. Escape functions:
    # Create list of common functions sorted in descending length order. 
    func_list:=ListTools:-Reverse(sort([op](common_function_names),':-length'));

    # Add "%" to start of all these common functions in the input.
    for funcname in func_list do:
        newEXPRESSION:=StringTools:-SubstituteAll(newEXPRESSION,funcname,cat("%",funcname));
    end do;
    
    # Fix the '%%cosh' that might have appeared.
    newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"%%","%");
    
    # Fix the 'arc%' that might have appeared.
    newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"arc%","arc");
    
    # Fix the '%h' that might have appeared.
    #newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"%h","h");
    
    # Capitalise "sum" and "int" occurring in the string. (Redundant now that they are in common_function_names?)
    for opname in ["sum","int"] do:
        newEXPRESSION:=StringTools:-SubstituteAll(newEXPRESSION,opname,StringTools:-Capitalize(opname));
    end do;
    
    # Replace any occurrences of "Pi" with "pi", and "I" with "i" for better presentation
    # (prevents any multiplication signs from appearing between these constants and expressions that precede them).
    newEXPRESSION:=StringTools:-RegSubs("([^A-Za-z0-9]|^)Pi([^A-Za-z0-9]|$)"="\\1pi\\2",newEXPRESSION);
    newEXPRESSION:=StringTools:-RegSubs("([^A-Za-z0-9]|^)I([^A-Za-z0-9]|$)"="\\1i\\2",newEXPRESSION);

    ## 3. Convert string to inert form:
    InertForm:-Parse(newEXPRESSION);

    ## 4. Parse select aspects of the inert form expression for correct MathML generation:

    # Parse any `Matrix` and `Vector` functions; converts to standard "< >" form.
    RESPONSE:=eval(%,{`%Matrix`=Matrix,`%Vector`=Vector});
    # Parse any "< >" vectors/matrices.
    RESPONSE:=eval(RESPONSE,{`%<,>`=`<,>`,`%<|>`=`<|>`,`%\`<,>\``=`<,>`,`%\`<|>\``=`<|>`});
    
    # Parse exponents, fractions/division, square roots, exponentials and absolute values.
    RESPONSE:=eval(RESPONSE,{`%^`=`^`,`%/`=`/`,`%sqrt`=`sqrt`,`%%exp`=(xx-> e^xx),`%%abs`=:-abs});
    
    # This resolves a bug in Maple2019 where an expression like 1-(1-1) is previewed as 1-1-1.
    RESPONSE:=eval(RESPONSE,{`%+`=`+`});

    # Convert inert form expression to MathML string and concatenate onto Message.
    Message:=cat(Message,InertForm:-ToMathML(%));

    ## 5. Modify HTML string to replace escaped values with original values and improve presentation. 
    # - Remove any remaining "%"'s.
    # - Replace "NUMBER" and "DECIMALDOT" expressions with appropriate outputs.
    # - Replace "&InvisibleTimes;" with explicit "&times;" between numerics.

    Message:=StringTools:-SubstituteAll(Message,"%","");
    
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)</mi>"="<mn>\\1</mn>",Message);
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)DECIMALDOT*([0-9]*)</mi>"="<mn>\\1.\\2</mn>",Message);
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)DECIMALDOT</mi>"="<mn>\\1.</mn>",Message);
    Message:=StringTools[RegSubs]("<mn>NUMBER([0-9]+)</mn>"="<mn>\\1.</mn>",Message);
    Message:=StringTools[SubstituteAll](Message,"</mn><mo>&InvisibleTimes;</mo><mn>","</mn><mo>&times;</mo><mn>");
    
    Message:=StringTools[RegSubs]("(</mn></[a-z]+>)<mo>&InvisibleTimes;</mo><mn>"="\\1<mo>\\&times;</mo><mn>",Message);
    Message:=StringTools[RegSubs]("</mn><mo>&InvisibleTimes;</mo>(<[a-z]+><mn>)"="<\/mn><mo>\\&times;</mo>\\1",Message);
    Message:=StringTools[RegSubs]("(</mn></[a-z]+>)<mo>&InvisibleTimes;</mo>(<[a-z]+><mn>)"="\\1<mo>\\&times;</mo>\\2",Message);
    
    ## 6. Remove the brackets from "listifying" the material, and return HTML string.
    mfenced_pattern_to_replace:=StringTools:-RegSub("(<mfenced[^>]*>)",%, "\\1");
    Message:=StringTools:-Substitute(Message,mfenced_pattern_to_replace,"<mfenced open='' close=''>");
    
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

# The following proc takes the student input string and a partially built HTML message string, and adds advice to the message string where it finds potential issues in the input string.
# This proc is only called if the string returns no Maple errors.

add_semantic_advice:=proc(EXPRESSION,InputMessage) local m0,m1,m2,m3,m4,m5,m6,Message,RESPONSE,hasBadInfinity,hasBadMult,func_name,regex_literal_op,regex_expression,_op; global common_function_names, common_operators, common_regex_literal_operators;

    # Save the HTML message string, ready to append feedback for students.
    Message:=InputMessage;
    # Save and parse the student input string as a Maple expression.
    RESPONSE:=parse(EXPRESSION);
    
    # Add a blank line below the MathML.
    Message:=cat(Message,"<p>&nbsp;</p>");

    ## Concatenate a line of advice to the HTML message string whenever issues are detected:

    # Search for occurrences of ":=" in the original input string:
    if evalb(max(StringTools:-Search([":="],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You probably shouldn't have ':=' in your input.</p>");
    end if;
    
    # Search for occurrences of ";" in the original input string:
    if evalb(max(StringTools:-Search([";"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You probably shouldn't have a semi-colon ';' in your input.</p>");
    end if;
    
    # Search for occurrences of the variable `e`:
    if e in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable e. Remember that the Maple notation for the exponential function is exp; you probably mean exp(1).</p>");
    end if;
    
    # Search for occurrences of the function `In`:
    if nops(indets([RESPONSE],'In(anything)'))>0 then
        Message:=cat(Message,"<p><strong>Advice:</strong> The name of the natural logarithm is spelt using a lowercase L and lowercase N.</p>");
    end if;
    
    # Search for occurrences of the variable `pi`:
    if pi in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable pi (with a lowercase P). Remember that the Maple notation for the numerical constant is Pi (with an uppercase P).</p>")
    end if;
    
    # Search for occurrences of the variable `PI`:
    if PI in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable PI (with an uppercase I). Remember that the Maple notation for the numerical constant is Pi (with a lowercase I).</p>")
    end if;

    # Search for occurrences of the variable `i`:
    if i in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable i (with a lowercase I). Remember that the Maple notation for the imaginary unit is I (with an uppercase i).</p>")
    end if;
    
    # Search input string for occurrences of ")(", indicating missing *:
    if evalb(max(StringTools:-Search([")("],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains ')(', did you mean ')*('? Did you forget a multiplication sign?</p>");
    end if;
    
    # Search input string for occurrences of numeric preceding "(", indicating missing *:
    # (Currently flags functions ending with numeric, such as `p1` or `p_1`.)
    if
        evalb(StringTools[RegMatch]("([0-9]+)(\\()",EXPRESSION,m0,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains ",m0,", did you mean ",m1,"*",m2,"? Parts of your expression might have vanished.</p>");
    end if;

    # This subproc checks for instance of `inf` not a substring of `infinity`; may be a case of misspelling the correct Maple quantity.
    hasBadInfinity := proc(stringToCheck) local i,strLen,stringToCheckLowercase;
        strLen := length(stringToCheck);
        stringToCheckLowercase := StringTools:-LowerCase(stringToCheck);
        
        # Escape immediately if no instances of `inf` (not case sensitive) occur in the input.
        if evalb(StringTools:-Search("inf", stringToCheckLowercase)=0) then
            return false
        end if;
        
        # Otherwise, `inf` occurs in the student input. Checks proceed as follows:
        # - if the student input is <8 characters, then return true
        # - otherwise, search the student input:
        #   - if input contains `inf` before 7th last character not the start of `infinity` then return true
        #   - else if input contains `inf` at or after 7th last character then return true
        #   - otherwise return false
        if 
            evalb(strLen < 8) 
        then
            return true
        else            
            for i from 1 to strLen-7 do
                if 
                    evalb(stringToCheckLowercase[i..i+2]="inf" and stringToCheck[i..i+7]<>"infinity")
                then
                    return true
                end if
            end do;
            for i from strLen-6 to strLen-3 do
                if 
                    evalb(stringToCheckLowercase[i..i+2]="inf")
                then
                    return true;
                end if;
                return false;
            end do; 
        end if;
    end proc;

    # This subproc parses the input string, isolates indeterminate terms, and checks the terms as strings for spelling against common functions and Greek letters.
    # Only triggered on an indet if it contains two adjacent letters (and no instance of "Vector" or "Matrix" expressions).
    # The following outputs are possible:
    # 0: all variable and function names in student input pass all checks
    # 1: a variable name is a common function name e.g. `sin`
    # 2: a variable name contains common function name as a strict substring e.g. `sinx`
    # 3: a variable name contains a Greek letter as a strict substring e.g. `gammax`
    # 4: a variable name contains at least two adjacent letters and is none of cases 1-3 e.g. `uv` or `xy`
    # 5: a function name contains common function name as a strict substring e.g. `xsin`
    # 6: a function name contains a Greek letter as a strict substring e.g. `nGamma`
    # 7: a function name contains at least two adjacent letters and is none of cases 5-6 e.g. `xf` or `th`
    # In cases 1-7 above, two additional outputs are given
    # - the Greek letter or common function name compared to the offending indet (where possible, otherwise ""), and
    # - the indet in the student input which triggered hasBadMult.
    hasBadMult := proc(stringToCheck) local parsedString,vList,fList,i,v_flag,f_flag,tag_name,greek_letters; global common_function_names;
	    greek_letters :=
            [   "alpha",   "beta",  "gamma",   "delta"
            ,   "epsilon", "zeta",  "eta",     "theta"
            ,   "iota",    "kappa", "lambda",  "mu"
            ,   "nu",      "xi",    "omicron", "pi"
            ,   "rho",     "sigma", "tau",     "upsilon"
            ,   "phi",     "chi",   "psi",     "omega"
            ,   "Alpha",   "Beta",  "Gamma",   "Delta"
            ,   "Epsilon", "Zeta",  "Eta",     "Theta"
            ,   "Iota",    "Kappa", "Lambda",  "Mu"
            ,   "Nu",      "Xi",    "Omicron", "Pi"
            ,   "Rho",     "Sigma", "Tau",     "Upsilon"
            ,   "Phi",     "Chi",   "Psi",     "Omega"];
        parsedString := parse(stringToCheck);
        indets([parsedString]);

        # Extract variable indets (excluding function and exponent expressions such as a^x or f(t)).
        vList := map(convert,convert(remove(xx->type(xx,`^`),remove(xx->type(xx,function),%)),list),string);
        # Extract function indets.
        fList := map(convert,convert(map2(op,0,select(xx->type(xx,function),%%)),list),string);

        # For pure indet variables, check whether:
        # - variable contains adjacent letters (but not "parsedString", and not containing "Matrix" or "Vector"),
        # - variable contains or is a common function name,
        # - variable contains or is a Greek letter,
        # and report first offender.
        for i from 1 to nops(vList) do
        	v_flag := 0;
		    if evalb(StringTools:-RegMatch("[a-z][a-z]",StringTools:-LowerCase(vList[i])) and vList[i]<>"parsedString" and StringTools:-Search(["Vector","Matrix"],vList[i])=[0,0]) then
			    for tag_name in ListTools:-Reverse(sort([op(common_function_names),"Vector","Matrix"],length)) do
			    	if evalb(tag_name=vList[i]) then
			    		return 1,tag_name,vList[i]
			    	elif evalb(StringTools:-Search(tag_name, vList[i])<>0) then
			    		return 2,tag_name,vList[i]
			    	end if
			    end do;
			    for tag_name in ListTools:-Reverse(sort(greek_letters,length)) do
			    	if evalb(tag_name=vList[i]) then
			    		v_flag := 1;
			    		break
			    	elif evalb(StringTools:-Search(tag_name, vList[i])<>0) then
			    		return 3,tag_name,vList[i]
			    	end if
			    end do;
			    if evalb(v_flag = 0) then return 4,"",vList[i] end if
	    	end if
	    end do;

        # For pure indet functions, check whether:
        # - variable contains adjacent letters (but not "parsedString", and not containing "Matrix" or "Vector"),
        # - variable contains or is a common function name,
        # - variable contains or is a Greek letter,
        # and report first offender.
	    for i from 1 to nops(fList) do
	    	v_flag := 0;
	    	f_flag := 0;
		    if evalb(StringTools:-RegMatch("[a-z][a-z]",StringTools:-LowerCase(fList[i])) and fList[i]<>"parsedString") then
			    for tag_name in ListTools:-Reverse(sort([op(common_function_names),"Vector","Matrix"],length)) do
				    if evalb(tag_name=fList[i]) then
					    f_flag := 1;
					    break;
				    elif evalb(StringTools:-Search(tag_name, fList[i])<>0) then
				    	return 5,tag_name,fList[i]
				    end if
			    end do;
			    if evalb(f_flag = 0) then
			    	for tag_name in ListTools:-Reverse(sort(greek_letters,length)) do
			    		if evalb(tag_name=fList[i]) then
			    			v_flag := 1;
			    			break
			    		elif evalb(StringTools:-Search(tag_name, fList[i])<>0) then
			    			return 6,tag_name,fList[i]
			    		end if
			    	end do;
			    	if evalb(v_flag = 0) then return 7,"",fList[i] end if
			    end if
	    	end if
	    end do;

        # Otherwise report all clear.
        return 0;
    end proc;

    # Search input string for triggers of `hasBadInfinity` or `hasBadMult`.
    # If hasBadInfinity is triggered then hasBadMult output is ignored.
    # Otherwise if hasBadMult is triggered then a message is displayed depending on the nature of the indet which triggered hasBadMult.
    m6 := hasBadMult(EXPRESSION);
    if
        hasBadInfinity(EXPRESSION)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> You may have incorrectly inputted &infin; in your answer. The Maple syntax for &infin; is &quot;infinity&quot; (the whole word, all lowercase letters).</p>");
    elif
        evalb(m6[1]=1)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the variable &quot;",m6[3],"&quot;, which is a common Maple function. Is this a typo (missing parentheses and function input)?</p>");
    elif
        evalb(m6[1]=2)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the variable &quot;",m6[3],"&quot;, which contains the substring &quot;",m6[2],"&quot;, which is a common Maple function. Is this a typo (missing parentheses and/or *)?</p>");
    elif
        evalb(m6[1]=3)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the variable &quot;",m6[3],"&quot;, which contains the substring &quot;",m6[2],"&quot;, which is a Greek letter. Is this a typo (missing parentheses and/or *)?</p>");
    elif
        evalb(m6[1]=4)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the variable &quot;",m6[3],"&quot;\; is this a typo (missing *)?</p>");
    elif
        evalb(m6[1]=5)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the function &quot;",m6[3],"&quot;, which contains the substring &quot;",m6[2],"&quot;, which is a common Maple function. Is this a typo (missing *)?</p>");
    elif
        evalb(m6[1]=6)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the function &quot;",m6[3],"&quot;, which contains the substring &quot;",m6[2],"&quot;, which is a Greek letter. Is this a typo (missing *)?</p>");
    elif
        evalb(m6[1]=7)
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains the function &quot;",m6[3],"&quot;\; is this a typo (missing *)?</p>");
    end if;

    # Searches for ALL occurrences of common function name as operands of common binary operators (e.g. "sin+", "exp^"):
    for func_name in common_function_names do
        for regex_literal_op in common_regex_literal_operators do
            regex_expression:=cat("(",func_name,")",regex_literal_op);
            if
                evalb(StringTools[RegMatch](regex_expression,EXPRESSION,m3,m4))
            then
                _op:=StringTools[SubstituteAll](regex_literal_op,"\\","");

                Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains ",m4,_op,", are you trying to type something like ",m4,"(x)?</p>");
                m3:='m3';m4:='m4';
            end if;
        end do;
    end do;
    
    # Return HTML string with advice based on student input.
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

# The following proc takes the student input string and a partially built HTML message string, and adds advice to the message string where it finds potential issues in the input string.
# This proc is only called if the student input string DOES return a Maple error. The input string is not parsed in this proc.
# Any advice here is in addition to the native Maple error message.

add_syntax_advice:=proc(EXPRESSION,InputMessage) local m0,m1,m2,Message,newEXPRESSION; global common_function_names,common_operators;
    
    # Save the HTML message string, ready to append feedback for students.
    Message:=InputMessage;
    
    # Add a blank line below the Maple syntax error message.
    Message:=cat(Message,"<p>&nbsp;</p>");
    
    ## Concatenate a line of advice to the HTML message string whenever issues are detected in the input string:

    # Search for occurrences of ":=": 
    if evalb(max(StringTools:-Search([":="],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You shouldn't have ':=' in your input.</p>");
    end if;
    
    # Search for occurrences of ";":
    if evalb(max(StringTools:-Search([";"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You shouldn't have ';' in your input.</p>");
    end if;
    
    # Search for occurrences of "/-":
    if evalb(max(StringTools:-Search(["/-"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> If you're trying to divide by a negative number then please put brackets around the denominator. You shouldn't have '/-' in your input.</p>");
    end if;
    
    # Search for occurrences of numeric followed immediately by letter, suggesting possible missing *:
    # (Note: May flag valid variables, e.g. `p1a`, unlikely to be asked for in exam setting.)
    if
        evalb(StringTools[RegMatch]("([0-9]+)([A-Za-z]+)",EXPRESSION,m0,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> Your expression contains ",m0,", did you mean ",m1,"*",m2,"? Remember to use the multiplication sign '*' for multiplication.</p>");
        m0:='m0'; m0:='m1'; m0:='m2';
    end if;
    
    # Search for occurrences of alphanumeric followed immediately by "<", suggesting possible missing *:
    if
        evalb(StringTools[RegMatch]("([0-9]+|[a-zA-z]|\\))(<)",EXPRESSION,m2,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains '",m1,"&lt;', did you mean '",m1,"*&lt;'? </p>");
        m0:='m0'; m0:='m1'; m0:='m2';
    end if;

    # Return HTML string with advice based on student input.
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

# This proc is the one used in Möbius for custom previewing. 
# It takes the student's  `$RESPONSE` and outputs a HTML message based on the input.

testmyexpression:=proc(EXPRESSION) local Message,Escaped_EXPRESSION,MessageTail,MATHML_EXPRESSION,syntax_error,RESPONSE; global common_function_names,common_operators;

    # Save student expression as a HTML-escaped string.
    Escaped_EXPRESSION:=StringTools:-Escape(EXPRESSION,'html');

    # Start the message string with HTML containing the student's literal input.
    Message:=cat("<p><strong>Input Expression</strong>: <span style=\"font-family: Consolas, monospace;color:darkred\">",Escaped_EXPRESSION,"</span></p>");
    # End the message string with the output of `displayMapleVersionNumber`, to be concatenated at the end.
    MessageTail:=displayMapleVersionNumber(""):

    # Return the message as-is if the student input is empty.
    if EXPRESSION="" then 
        return cat(Message,MessageTail);
    end if;

    # Otherwise, use a try-catch to attempt to parse the student input string. Broadly:
    # - if it can be parsed, then add output of create_MathML and add_semantic_advice above to Message.
    # - if it can't be parsed, then add Maple syntax error and add_syntax_advice above to Message.
    try
        # Check if expression can be parsed:
        RESPONSE := parse(EXPRESSION);
        
        # If it can, try to use create_MathML on it; if it fails, use MathML[ExportPresentation] instead.
        try
            # Check if expression is a function definition:
            if evalb(max(StringTools:-Search(["->"],EXPRESSION))>0) then
                # Replace "->" with marker "#".
                StringTools:-Substitute(EXPRESSION,"->","#");
                # Split string into two using marker "#".
                StringTools:-Split(%,"#");
                # Use create_MathML on both halves of the string, with a \mapsto in the middle, and append to Message.
                Message:=cat(Message,"<p align=\"center\">",create_MathML(%[1])," \\(\\mapsto\\) ",create_MathML(%[2]),"</p>");
            else
                # Probably not a function a definition, so apply create_MathML directly and append to Message.
                MATHML_EXPRESSION:=create_MathML(EXPRESSION);
                Message:=cat(Message,"<p align=\"center\">",MATHML_EXPRESSION,"</p>");
            end if;
        catch:
            # If something above goes wrong, it can still be parsed; use MathML:-ExportPresentation instead and compromise with whatever falls out.
            Message:=cat(Message,"<p align=\"center\">",MathML[ExportPresentation](parse(EXPRESSION)),"</p>");
        end try;

        # Add output of add_semantic_advice to Message.
        Message:=add_semantic_advice(EXPRESSION,Message) ;
        
        # Conclude by concatenating the output of displayMapleVersionNumber to Message.
        return cat(Message,MessageTail);
    catch:
        # Otherwise it can't be parsed. Concatenate error message:
        Message:=cat(Message," <p>Invalid Maple syntax or input.</p> ");
        
        # Fetch error message from lastexception and modify string for easier-to-understand language for students, then append to Message.
        syntax_error:=StringTools:-FormatMessage(lastexception[2..-1]);
        syntax_error:=StringTools:-Substitute(syntax_error,"incorrect syntax in parse:","");
        syntax_error:=StringTools:-Substitute(syntax_error,"`;` unexpected","unexpected end of input");
        syntax_error:=StringTools:-Substitute(syntax_error,"missing operator or `;`","missing operator");
        syntax_error:=StringTools:-RegSubs("\\(near [0-9]+[a-z]* character of parsed string\\)"="",syntax_error);
        Message:=cat(Message,"<p><strong>Reported error: </strong>",syntax_error,"</p>");

        # Add output of add_syntax_advice to Message.
        Message:=add_syntax_advice(EXPRESSION,Message):

        # Conclude by concatenating the output of displayMapleVersionNumber to Message.
        return cat(Message,MessageTail)
    end try
end proc;

#####################################################################
#                                                                   #
#####################################################################

## Create the library using the above variables.

# Put the version numbers in a list for filenames.
# (List format obsolete)
library_name_list:=
[
    MaplePreviewerVersion()
];

# Replace "." with "_", deletes non-(alphanumerics(and _ and -'s)) for filename.
library_name_list:=
    map(xx->StringTools:-RegSubs("[ .]" = "_",xx),library_name_list);
library_name_list:=
    map(xx->StringTools:-RegSubs("[^A-Za-z0-9_-]" = "",xx),library_name_list);

# Concatenate "maple_preview_code_" with prepared version number and ".mla".
librarynames:=map2(cat,"maple_preview_code_",library_name_list,".mla");

# Call Maple archive manager (march) to create two identical archives:
# - maple_preview_code_X_X_X.mla, for use in Mobius, and
# - MapleCustomPreviewer.mla, for use by TestingThePreviewer.mpl (no need to update that file each version).
for ii in [op(librarynames),"MapleCustomPreviewer.mla"] do
    march('create',ii):
    savelib('MaplePreviewerVersion',ii);
    savelib('common_function_names',ii);
    savelib('common_operators',ii);
    savelib('common_regex_literal_operators',ii);
    savelib('add_syntax_advice',ii);
    savelib('add_semantic_advice',ii);
    savelib('create_MathML',ii);
    savelib('testmyexpression',ii);
    savelib('displayMapleVersionNumber',ii);
end do;



