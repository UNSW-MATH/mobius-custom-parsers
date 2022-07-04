MatlabPreviewerVersion := proc() return "0.1.0" end proc;

matlab_function_replacement_list := [["asin","arcsin"]
                                    ,["acos","arccos"]
                                    ,["atan","arctan"]
                                    ,["asec","arcsec"]
                                    ,["acsc","arccsc"]
                                    ,["acot","arccot"]
                                    ,["asinh","arcsinh"]
                                    ,["acosh","arccosh"]
                                    ,["atanh","arctanh"]
                                    ,["asech","arcsinh"]
                                    ,["acsch","arccsch"]
                                    ,["acoth","arccoth"]
                                    ,["nchoosek","binomial"]
                                    ,["log","ln"]];

matlab_variable_replacement_list := [["pi","Pi"]
                                    ,["i","I"]];                               
                                    
maple_common_function_names := ["arcsinh","arccosh","arctanh","arccsch","arccoth","arcsech"
                               ,"arcsin" ,"arccos" ,"arctan" ,"arccsc" ,"arccot" ,"arcsec"
                               ,"sinh","cosh","tanh","csch","coth","sech"
                               ,"sin" ,"cos" ,"tan" ,"csc" ,"cot" ,"sec"
                               ,"log","ln"];
                               

                               
CheckForMapleNotation := proc(inputString) local item,parsedExpression;
    for item in matlab_function_replacement_list do
        if StringTools:-Search(item[2],inputString) > 0 then
            error "Unknown Matlab function: %1",item[2]
        end if;
    end do;
    
    parsedExpression := Matlab:-FromMatlab(inputString,string=true);
    
    for item in matlab_variable_replacement_list do
        if StringTools:-Search(cat("m_",item[2]),parsedExpression) > 0 then
            error "Unknown Matlab variable: %1",item[2]
        end if;
    end do;
    
    
end proc;

                               
decode_common_function_names := proc(inputExpression) local expression;
    expression := inputExpression;

    #for item in maple_common_function_names do
    #    expression := 
    #         subs(
    #             parse(cat(item,"_MAPLE_FUNCTION")) = parse(item)
    #            ,expression
    #         ):
    #end do:

    convert(expression,string);
    StringTools:-SubstituteAll(%,"_MAPLE_FUNCTION","");
    expression := parse(%);

    return expression
end proc;            
                                    
# Modify the matlab string to replace matlab functions
# with standard Maple funcitons.
#   
MatlabStringModify := proc(inputString) local modifiedString;
    modifiedString:=StringTools:-Trim(inputString):

    # Replace Maple specific names with explicitly labelled functions
    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[2],cat("MAPLE_",item[2])):
    end do:

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
    
    # Fix issues with the complex number '1/2i' (which is 1/2/i in matlab)
    modifiedString := StringTools:-RegSubs("/[[:space:]]*([0-9]+)[ij]([^A-Za-z]|$)"="/\\1/i\\2",modifiedString);
    
    # Fix issues with the complex number 'i'
    modifiedString := StringTools:-RegSubs("(^|[^A-Za-z])([0-9]+)[ij]([^A-Za-z]|$)"="\\1\\2*i\\3",modifiedString);
    
    return modifiedString;
end proc;

FormatMatlabSyntaxError := proc(ExpressionString,ErrorString)
   StringTools:-Split(ErrorString,"\n");
   [%[2],StringTools:-Substitute(%[3],"^","&uarr;")];
   StringTools:-Join(%,"<br>");
   StringTools:-SubstituteAll(%," ","&nbsp;");
   cat("<p>Matlab Syntax Error:</p><p style=font-family:consolas,monospace;color:red>",%,"</p><p>Please check your input.</p>");
   
   return %;
end proc;

FormatMatlabException := proc(ExpressionString,ErrorString)
   cat(ExpressionString,"<br>",ErrorString);
   return %;
end proc;

SuggestCorrectMatlabExpression := proc(ExpressionString) local Message,modifiedString,item;
   Message:=cat("<p style=font-family:consolas,monospace;>",ExpressionString,"</p>");
   
   StringTools:-FormatMessage(_rest);
   cat("<p style=color:red>",%,"</p>");
   Message:=cat(Message,%);
   
   modifiedString:=ExpressionString;
   for item in matlab_function_replacement_list do
        modifiedString:=StringTools:-SubstituteAll(modifiedString,item[2],item[1])
   end do:
   
   if modifiedString <> ExpressionString then
       cat("<p>Did you mean:</p>","<p style=font-family:consolas,monospace;>",modifiedString,"</p>");
       Message:=cat(Message,%);
       
       return Message;
   end if;
   
   for item in matlab_variable_replacement_list do
        modifiedString:=StringTools:-SubstituteAll(modifiedString,cat("m_",item[2]),item[1])
   end do:
      
   if modifiedString <> ExpressionString then
       cat("<p>Did you mean:</p>","<p style=font-family:consolas,monospace;>",modifiedString,"</p>");
       Message:=cat(Message,%);
       
       return Message;
   end if;
      
   return Message;
end proc;


# Parse a string containing a Matlab expression into a Maple object
#   Maple functions will be transated into 'MAPLE_<function_name>' to
#   allow for optional reparsing.
MatlabExpressionParse := proc(inputString) local modifiedString;
    
    modifiedString := MatlabStringModify(inputString);
    
    MatlabString := Matlab:-FromMatlab(modifiedString, string = true); 
    modifiedString := StringTools:-SubstituteAll(%, "evalhf", "");
    modifiedString := StringTools:-SubstituteAll(%, "Matlab_i", "I");
      
    expression := parse(modifiedString);
    expression := %;
    
    expression := decode_common_function_names(expression);
    expression := eval(%,i=I);
    
    return expression;
    
end proc;

CustomPreviewMatlab := proc(inputString) local expression,modifiedString,MatlabString;
    if inputString = "" then
        return ""
    end if;

    try
    CheckForMapleNotation(inputString);
    
    expression := MatlabStringModify(inputString):
    MatlabString := Matlab:-FromMatlab(expression, string = true); 
    modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", ""); 
    modifiedString := StringTools:-SubstituteAll(%, "Matlab_i", "I");
    modifiedString := StringTools:-SubstituteAll(%, "m_factorial", "factorial");
    modifiedString := StringTools:-SubstituteAll(%, "m_binomial", "binomial");
    
    expression := parse(modifiedString);
    
    expression := decode_common_function_names(expression);
    MathML:-ExportPresentation(%); 
    
    Message:=cat("<p align=\"center\">",%,"</p>");
        
    return Message;
 
    catch "on line 1, syntax error":
        Message := FormatMatlabSyntaxError(inputString,lastexception[2])
    catch "numeric exception":
        Message := FormatMatlabException(inputString,lastexception[2])
    catch "Unknown Matlab":
        Message := SuggestCorrectMatlabExpression(inputString,lastexception[2..]); 
    catch:
        Message:= cat("<p style=font-family:consolas,monospace align=center>",inputString,"</p><p>Unexpected error occured, please take a screenshot and send this to your course M&ouml;bius contact.<br>If this is a test or exam, please assume your expression is formatted correctly and continue working.</p>");
    end try;    
    
    return Message;   
end proc;

libraryname := "PreviewMatlabExpression.lib";
march('create',libraryname):
savelib('MatlabStringModify'
       ,'CheckForMapleNotation'
       ,'SuggestCorrectMatlabExpression'
       ,'MatlabExpressionParse'
       ,'FormatMatlabSyntaxError'
       ,'FormatMatlabException'
       ,'CustomPreviewMatlab'
       ,'matlab_function_replacement_list'
       ,'matlab_variable_replacement_list'
       ,'maple_common_function_names'
       ,'decode_common_function_names'
       ,'MatlabPreviewerVersion'
       ,libraryname);


#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf(Message);
#

