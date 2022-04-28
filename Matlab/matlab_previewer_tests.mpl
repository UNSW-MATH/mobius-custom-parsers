
libname := libname,"PreviewMatlabExpression.lib";

TestExpressions :=
   ["[1,1,2]","[1 sqrt(2), pi]","1,1,1"
   ,"sin(3*x)","cos(2*x)","cosh(2*x+y)","tanh(3*x+5*y)","coth(a*b+c*d)"
   ,"[sin(3*x),cos(2*x),cosh(2*x+y);tanh(3*x+5*y),coth(a*b+c*d),tan(2*x+d*y)]"
   ,"asin(x*y)","arcsin(3*x)"
   ,"nchoosek(3,2)","nchoosek(n,k)"
   ,"x,y,z"
   ,"1/-2","1*-2"];

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
