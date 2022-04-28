MatlabPreviewerVersion := proc() return "0.0.1" end proc;

matlab_function_replacement_list := [["asin","arcsin"]
                                    ,["acos","arccos"]
                                    ,["atan","arctan"]
                                    ,["asec","arcsec"]
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

maple_common_function_names := ["arcsin","arccos","arctan","arccsc","arccot","arcsec"
                               ,"sinh","cosh","tanh","csch","coth","sech"
                               ,"sin" ,"cos" ,"tan" ,"csc" ,"cot" ,"sec"
                               ,"log","ln"];
                               
decode_common_function_names := proc(inputExpression) local expression;
    expression := inputExpression;

    for item in maple_common_function_names do
        expression := 
             subs(
                 parse(cat(item,"_MAPLE_FUNCTION")) = parse(item)
                ,expression
             ):
    end do:
    
    return expression
end proc;            
                                    
# Modify the matlab string to replace matlab functions
# with standard Maple funcitons.
#   
MatlabStringModify := proc(inputString) local modifiedString;
    modifiedString:=StringTools:-Trim(inputString):

    # Replace Matlab names function with Maple names
    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[1],item[2]):
    end do:

    # Protect Maple function names from breaking over elementwise operations inside a matrix
    for item in maple_common_function_names do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,cat(item,"("),cat(item,"_MAPLE_FUNCTION(")):
    end do:

    # Fix issues with missing brackets around denominators
    modifiedString := StringTools:-SubstituteAll(modifiedString,"/-","/(-1)/"):
    modifiedString := StringTools:-SubstituteAll(modifiedString,"*-","*(-1)*"):
    
    return modifiedString;
end proc;


# Parse a string containing a Matlab expression into a Maple object
MatlabExpressionParse := proc(inputString) local modifiedString;
    
    modifiedString := MatlabStringModify(inputString);print(%);
    
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
    
    expression := decode_common_function_names(expression);
    
    return expression;
    
end proc;

CustomPreviewMatlab := proc(inputString) local expression,modifiedString,MatlabString;
    if inputString = "" then
        return ""
    end if;
    
    if evalf(StringTools:-Search("[",inputString)>0) then
        expression := MatlabStringModify(inputString):
        MatlabString := Matlab:-FromMatlab(expression, string = true); 
        modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", ""); 
        expression := parse(modifiedString);
        
        expression := decode_common_function_names(expression);
        return MathML:-ExportPresentation(%); 
    else
        expression := MatlabStringModify(inputString):
        if evalb(StringTools:-Search("binomial",expression)>0) then
            expression := StringTools:-SubstituteAll(expression,"binomial","C")
        end if;
        expression := InertForm:-Parse(expression);
        expression := InertForm:-Value(expression);
        
        expression := decode_common_function_names(expression);
        return InertForm:-ToMathML(expression)
    end if;
    
    
    
end proc;

libraryname := "PreviewMatlabExpression.lib";
march('create',libraryname):
savelib('MatlabStringModify'
       ,'MatlabExpressionParse'
       ,'CustomPreviewMatlab'
       ,'matlab_function_replacement_list'
       ,'maple_common_function_names'
       ,'decode_common_function_names'
       ,'MatlabPreviewerVersion'
       ,libraryname);


#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf(Message);
#

