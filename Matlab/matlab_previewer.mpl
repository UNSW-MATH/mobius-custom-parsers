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

MatlabExpressionParse := proc(inputString) local modifiedString;
    modifiedString:=StringTools:-Trim(inputString):

    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[1],item[2]):
    end do:

    return modifiedString;
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
        expression := MatlabExpressionParse(inputString):
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
savelib('MatlabExpressionParse'
       ,'CustomPreviewMatlab'
       ,'matlab_function_replacement_list'
       ,libraryname);


#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf(Message);
#


#======================================================================
# Comment out 'quit;' to run the tests below
#======================================================================
quit;

TestExpressions :=
   ["[1,1,2]","[1 sqrt(2), pi]","1,1,1","sin(x)"
   ,"asin(x)","asinh(x)"];

#======================================================================
#======================================================================

interface(quiet=true);

writeto("HTML_examples.html");

printf("<!DOCTYPE html>");
printf("<html>");
printf("<head>");
printf("  <meta charset=\"utf-8\">");
printf("  <title>Fullest MathML support using MathJax</title>");
printf("  <script>window.MathJax = { MathML: { extensions: [\"mml3.js\", \"content-mathml.js\"]}};</script>");
printf("<script type=\"text/javascript\" async src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=MML_HTMLorMML\"></script>");
printf("</head>\n\n<body>\n");

printf("<p>");
    printf(StringTools:-FormatTime("%c %Z"));
    printf("");
    printf("</p><hr><p>");

for expression_ in TestExpressions do
    printf(cat(expression_,"<br>"));
    Message:=CustomPreviewMatlab(expression_):
    printf(Message);
    printf("</p><hr><p>");
    
end do:

printf("</p>");
printf("</body>\n</html>");

writeto(terminal);
