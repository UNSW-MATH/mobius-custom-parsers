# Would've been needed if compiling for Maple TA's old 2015 kernel.
# libname:="/home/z3099630/.local/maple2015lib";

MaplePreviewerVersion := proc() return "1.0.3" end proc;

displayVersionNumber:=proc(inputString)
    VersionNumber:=MaplePreviewerVersion():
    versionMessage:=sprintf("<p style=\"text-align: right;color: #12b0fd;\" title=\"Contact Joshua Capel (j.capel@unsw.edu.au) to report errors.\">UNSW M&ouml;bius Custom Previewer v%s</p>",VersionNumber):

    return cat(inputString,versionMessage):
end proc;

#####################################################################
#                                                                   #
#####################################################################

common_function_names:=
    ["exp","ln","log","abs"
    ,   "sin" ,   "cos" ,   "tan" ,   "cot" ,"sec"
    ,   "sinh",  "cosh" ,   "tanh",   "coth","sech"
    ,"arcsin" ,"arccos" ,"arctan" ,"arccot" ,"arcsec"
    ,"arcsinh","arccosh","arctanh","arccoth","arcsech"];

common_operators:=["*","-","+","*","^"];
common_regex_literal_operators:=["\\*","\\+","-","\\^"];

forbidden_symbols:={"{","}","[","]"};

#####################################################################
#                                                                   #
#####################################################################

create_MathML:=proc(EXPRESSION) local Message; global common_function_names,common_operators;

    Message:="":
    # Capture input in a list (to be fixed before returning)
    newEXPRESSION:=cat("[",EXPRESSION,"]");
    
    if evalb(max(StringTools:-Search(["Matrix","Vector"],newEXPRESSION))=0) then
        newEXPRESSION:=StringTools[RegSubs]("([0-9]+)\\."="\\1DECIMALDOT",newEXPRESSION);
        newEXPRESSION:=StringTools[RegSubs]("([0-9]+)"="NUMBER\\1",newEXPRESSION);
        newEXPRESSION:=StringTools[RegSubs]("([a-zA-Z])NUMBER"="\\1",newEXPRESSION);
    end if;
    
    func_list:=ListTools:-Reverse(sort([op](common_function_names),':-length'));
    
    for funcname in func_list do:
        newEXPRESSION:=StringTools:-SubstituteAll(newEXPRESSION,funcname,cat("%",funcname));
    end do;
    
    #Fix the '%%cosh' that might have appeared
    newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"%%","%");
    
    #Fix the 'arc%' that might have appeared
    newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"arc%","arc");
    
    ##Fix the '%h' that might have appeared
    #newEXPRESSION:=StringTools[SubstituteAll](newEXPRESSION,"%h","h");
    
    for opname in ["sum","int"] do:
        newEXPRESSION:=StringTools:-SubstituteAll(newEXPRESSION,opname,StringTools:-Capitalize(opname));
    end do;
    
    newEXPRESSION:=StringTools:-SubstituteAll(newEXPRESSION,"Pi","pi");
    
    
    InertForm:-Parse(newEXPRESSION);
    RESPONSE:=eval(%,{`%<,>`=`<,>`,`%<|>`=`<|>`,`%\`<,>\``=`<,>`,`%\`<|>\``=`<|>`});
    
    #RESPONSE:=eval(RESPONSE,{`%+`=`+`});
    RESPONSE:=eval(RESPONSE,{`%^`=`^`,`%/`=`/`,`%sqrt`=`sqrt`,`%%exp`=(xx-> e^xx),`%%abs`=:-abs});
    
    # This resolves a bug in Maple2019 where an expression like 1-(1-1) is previewed as 1-1-1.
    RESPONSE:=eval(RESPONSE,{`%+`=`+`});
    Message:=cat(Message,InertForm:-ToMathML(%));
    Message:=StringTools:-SubstituteAll(Message,"%","");
    
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)</mi>"="<mn>\\1</mn>",Message);
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)DECIMALDOTNUMBER*([0-9]*)</mi>"="<mn>\\1.\\2</mn>",Message);
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)DECIMALDOT*([0-9]*)</mi>"="<mn>\\1.\\2</mn>",Message);
    Message:=StringTools[RegSubs]("<mi>NUMBER([0-9]+)DECIMALDOT</mi>"="<mn>\\1.</mn>",Message);
    Message:=StringTools[RegSubs]("<mn>NUMBER([0-9]+)</mn>"="<mn>\\1.</mn>",Message);
    Message:=StringTools[SubstituteAll](Message,"</mn><mo>&InvisibleTimes;</mo><mn>","</mn><mo>&times;</mo><mn>");
    
    Message:=StringTools[RegSubs]("(</mn></[a-z]+>)<mo>&InvisibleTimes;</mo><mn>"="\\1<mo>\\&times;</mo><mn>",Message);
    Message:=StringTools[RegSubs]("</mn><mo>&InvisibleTimes;</mo>(<[a-z]+><mn>)"="<\/mn><mo>\\&times;</mo>\\1",Message);
    Message:=StringTools[RegSubs]("(</mn></[a-z]+>)<mo>&InvisibleTimes;</mo>(<[a-z]+><mn>)"="\\1<mo>\\&times;</mo>\\2",Message);
    
    # Remove the brackets from "listifying" the material
    mfenced_pattern_to_replace:=StringTools:-RegSub("(<mfenced[^>]*>)",%, "\\1");
    Message:=StringTools:-Substitute(Message,mfenced_pattern_to_replace,"<mfenced open='' close=''>");
    
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

add_semantic_advice:=proc(EXPRESSION,InputMessage) local m0,m1,m2,m3,m4,m5,Message,RESPONSE; global common_function_names; common_operators, common_regex_literal_operators;

    Message:=InputMessage;
    RESPONSE:=parse(EXPRESSION);
    
    Message:=cat(Message,"<p>&nbsp;</p>");


    if evalb(max(StringTools:-Search([":="],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You probably shouldn't have ':=' in your input.</p>");
    end if;
    
    if evalb(max(StringTools:-Search([";"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You probably shouldn't have a semi-colon ';' in your input.</p>");
    end if;
    
    if e in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable e. Remember that the maple notation for the exponential is exp.</p>");
    end if;
    
    if nops(indets([RESPONSE],'In(anything)'))>0 then
        Message:=cat(Message,"<p><strong>Advice:</strong> The name of the natural log is spelt using a lowercase L and lower case N.</p>");
    end if;
    
    if pi in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable pi. Remember that the maple notation for numerical constant is Pi (capital P).</p>")
    end if;
    
    if PI in indets([RESPONSE]) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your answer contains the variable PI. Remember that the maple notation for numerical constant is Pi (lower case i).</p>")
    end if;
    
    if evalb(max(StringTools:-Search([")("],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains ')(', did you mean ')*('? Did you forget a multiplication sign?</p>");
    end if;
    
    if
        evalb(StringTools[RegMatch]("([0-9]+)(\\()",EXPRESSION,m0,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains ",m0,", did you mean ",m1,"*",m2,"? Parts of your expression might have vanished.</p>");
    end if;
    
    
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
    
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

add_syntax_advice:=proc(EXPRESSION,InputMessage) local m0,m1,m2,Message,newEXPRESSION; global common_function_names,common_operators;
    
    
    Message:=InputMessage;
    
    Message:=cat(Message,"<p>&nbsp;</p>");
    
    if evalb(max(StringTools:-Search([":="],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You shouldn't have ':=' in your input.</p>");
    #else try
    #    newEXPRESSION:=StringTools:-SubstituteAll(EXPRESSION,"^","&^");
    #    parse(newEXPRESSION);
    #    Message:=cat(Message,"<p><strong>Syntax advice:</strong> Possible ambiguous use of the ^ operator. Use (a^b)^c or a^(b^c) instead of a^b^c</p>");
    #catch:
    #end try;
    end if;
    
    if evalb(max(StringTools:-Search([";"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> You shouldn't have ';' in your input.</p>");
    end if;
    
    if evalb(max(StringTools:-Search(["/-"],EXPRESSION))>0) then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> If you're trying to divide by a negative number then please put brackets around the denominator. You shouldn't have '/-' in your input.</p>");
    end if;
    
    if
        evalb(StringTools[RegMatch]("([0-9]+)([A-Za-z]+)",EXPRESSION,m0,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Syntax advice:</strong> Your expression contains ",m0,", did you mean ",m1,"*",m2,"? Remember to use the multiplication sign '*' for multiplication.</p>");
        m0:='m0'; m0:='m1'; m0:='m2';
    end if;
    
    if
        evalb(StringTools[RegMatch]("([0-9]+|[a-zA-z]|\\))(<)",EXPRESSION,m2,m1,m2))
    then
        Message:=cat(Message,"<p><strong>Advice:</strong> Your expression contains '",m1,"&lt;', did you mean '",m1,"*&lt;'? </p>");
        m0:='m0'; m0:='m1'; m0:='m2';
    end if;
    
    return Message;
end proc;

#####################################################################
#                                                                   #
#####################################################################

testmyexpression:=proc(EXPRESSION) local Message, RESPONSE; global common_function_names,common_operators;

    Message:=cat("<p><strong>Input Expression</strong>: <span style=\"font-family: Consolas, monospace;color:darkred\">",EXPRESSION,"</span></p>");
    MessageTail:=displayVersionNumber(""):

    if EXPRESSION="" then 
        return cat(Message,MessageTail);
    end if;

    try
        #Check if expression can be parsed
        RESPONSE:=parse(EXPRESSION);
        
        ####### Force unseen errors to light
        ####### eval(%);
        
        try
            #Check if expression is a function definition
            if evalb(max(StringTools:-Search(["->"],EXPRESSION))>0) then
                StringTools:-Substitute(EXPRESSION,"->","#");
                StringTools:-Split(%,"#");
                Message:=cat(Message,"<p align=\"center\">",create_MathML(%[1])," \\(\\mapsto\\) ",create_MathML(%[2]),"</p>");
            else
                MATHML_EXPRESSION:=create_MathML(EXPRESSION);
                Message:=cat(Message,"<p align=\"center\">",MATHML_EXPRESSION,"</p>");
            end if;
        catch:
            Message:=cat(Message,"<p align=\"center\">",MathML[ExportPresentation](parse(EXPRESSION)),"</p>");
            
            #Message:=cat(Message,EXPRESSION,"<p><strong>Warning:</strong> Your expression may have syntax error. If advice below doesn't help then please report this to your lecture in charge of maple.</p>");
            #syntax_error:=StringTools:-FormatMessage(lastexception[2..-1]);
            #Message:=cat(Message,"<p><strong>Reported error: </strong>",syntax_error,"</p>");
            
        end try;
        Message:=add_semantic_advice(EXPRESSION,Message) ;
        
        return cat(Message,MessageTail);
    catch:
        Message:=cat(Message," <p>Invalid Maple Syntax or input.</p> ");
        
        syntax_error:=StringTools:-FormatMessage(lastexception[2..-1]);
        syntax_error:=StringTools:-Substitute(syntax_error,"incorrect syntax in parse:","");
        syntax_error:=StringTools:-Substitute(syntax_error,"`;` unexpected","unexpected end of input");
        syntax_error:=StringTools:-Substitute(syntax_error,"missing operator or `;`","missing operator");
        syntax_error:=StringTools:-RegSubs("\\(near [0-9]+[a-z]* character of parsed string\\)"="",syntax_error);
        Message:=cat(Message,"<p><strong>Reported error: </strong>",syntax_error,"</p>");

        
        Message:=add_syntax_advice(EXPRESSION,Message):

        return cat(Message,MessageTail);
    end try;
end proc;

library_name_list:=
[
     "2022_t1"
    ,"v9"
    ,MaplePreviewerVersion()
];

library_name_list:=
    map(xx->StringTools:-SubstituteAll(xx,".","_"),library_name_list);

librarynames:=map2(cat,"maple_preview_code_",library_name_list,".lib");
#print(%):

for ii in [op(librarynames),"MapleCustomPreviewer.lib"] do
    #next;
    march('create',ii):
    savelib('MaplePreviewerVersion',ii);
    savelib('common_function_names',ii);
    savelib('common_operators',ii);
    savelib('common_regex_literal_operators',ii);
    savelib('add_syntax_advice',ii);
    savelib('add_semantic_advice',ii);
    savelib('create_MathML',ii);
    savelib('testmyexpression',ii);
    savelib('displayVersionNumber',ii);
    #savelib(`&^`,ii);
end do;



