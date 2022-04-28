matlab_function_replacement_list := [["asin","arcsin"]
                                    ,["acos","arccos"]
                                    ,["atan","arctan"]
                                    ,["asec","arcsin"]
                                    ,["acsc","arccsc"]
                                    ,["acot","arccot"]
                                   #  These are not currently necessary
                                   #  due to the substitutions above.
                                   #,["asinh","arcsinh"]
                                   #,["acosh","arccosh"]
                                   #,["atanh","arctanh"]
                                   #,["asech","arcsinh"]
                                   #,["acsch","arccsch"]
                                   #,["acoth","arccoth"]
                                    ,["nchoosek","binomial"]
                                    ,["log","ln"]];

# Modify the matlab string to replace matlab functions
# with standard Maple funcitons.
#   
MatlabStringModify := proc(inputString) local modifiedString;
    modifiedString:=StringTools:-Trim(inputString):

    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[1],item[2]):
    end do:

    return modifiedString;
end proc;


# Parse a string containing a Matlab expression into a Maple object
MatlabExpressionParse := proc(inputString) local modifiedString;
    
    modifiedString := MatlabStringModify(inputString);
    if evalf(StringTools:-Search("[",inputString)>0) then
        MatlabString := Matlab:-FromMatlab(inputString, string = true); 
        modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", ""); 
        expression := parse(modifiedString);
    else
        expression := MatlabStringModify(inputString):
        if evalb(StringTools:-Search("binomial",expression)>0) then
            expression := StringTools:-SubstituteAll(expression,"binomial","C")
        end if;
        expression := InertForm:-Parse(expression);
        expression := InertForm:-Value(expression);
    end if;   
    
    return expression;
    
end proc;

CustomPreviewMatlab := proc(inputString) local expression,modifiedString,MatlabString;
    if inputString = "" then
        return ""
    end if;
    if evalf(StringTools:-Search("[",inputString)>0) then
        MatlabString := Matlab:-FromMatlab(inputString, string = true); 
        modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", ""); 
        expression := parse(modifiedString);
        return MathML:-ExportPresentation(%); 
    else
        expression := MatlabStringModify(inputString):
        if evalb(StringTools:-Search("binomial",expression)>0) then
            expression := StringTools:-SubstituteAll(expression,"binomial","C")
        end if;
        expression := InertForm:-Parse(expression);
        expression := InertForm:-Value(expression);
        return InertForm:-ToMathML(expression)
    end if;
end proc;

libraryname := "PreviewMatlabExpression.lib";
march('create',libraryname):
savelib('MatlabStringModify'
       ,'MatlabExpressionParse'
       ,'CustomPreviewMatlab'
       ,'matlab_function_replacement_list'
       ,libraryname);


#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf(Message);
#

