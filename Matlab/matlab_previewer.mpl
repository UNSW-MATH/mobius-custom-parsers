CustomPreviewMatlab := proc(inputString) local MatlabString,modifiedString,expression;

    if inputString = "" then
        return ""
    end if:

    MatlabString := Matlab:-FromMatlab(inputString, string=true );
    modifiedString := StringTools:-SubstituteAll(MatlabString,"evalhf","");
    expression := parse(modifiedString);
    #expression := InertForm:-Parse(modifiedString);
    #expression := InertForm:-Value(%);
    %;
    return MathML:-ExportPresentation(%);#expression);

end proc;


libraryname := "PreviewMatlabExpression.lib";
march('create',libraryname):
savelib('CustomPreviewMatlab',libraryname);

libraryname := "PreviewMatlabMatrix.lib";
march('create',libraryname):
savelib('CustomPreviewMatlab',libraryname);

#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf(Message);
#


#======================================================================
# Uncomment 'quit;' to run the tests below
#======================================================================
quit;

TestExpressions :=
   ["[1,1,2]","[1 sqrt(2), pi]","1,1,1","sin(x)"];

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
