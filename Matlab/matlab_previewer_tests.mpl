
libname := libname,"PreviewMatlabExpression.lib";

TestExpressions :=
   ["1/3i","1+1/2i","1 + 1 / 2i","1+1/2i+i/2"
   ,"a+bi","a+b*i","3+4*I","3+4i","3+4j","B2i"
   ,"[1,1,2]","[1 sqrt(2), pi]","1,1,1"
   ,"sin(3*x)","cos(2*x)","cosh(2*x+y)","tanh(3*x+5*y)","coth(a*b+c*d)"
   ,"[sin(3*x),cos(2*x),cosh(2*x+y);tanh(3*x+5*y),coth(a*b+c*d),tan(2*x+d*y)]"
   ,"asin(x*y)","arcsin(3*x)"
   ,"nchoosek(3,2)","nchoosek(n,k)"
   ,"x,y,z"
   ,"1/-2","1*-2"
   ,"factorial(n)"
   ,"1!","arcsin(x)+arccos(y)","2*I","sin(Pi)","ln(20)"
   ,"x + y + z = 1","x + y + z == 1"
   ,"[x y z]*[1 2 3]' == 1","[1 2 3]*[x y z]' == 1"
   ,"[1 + 3*i;1 - 3i]","[1 + 3*i;1 -3i]"
   ,"eye(3)","eye(2)"
   ,"eye(3)+x","eye(2)+3"
   ,"eye(3) + eye(2)"
   ,"eye(3) + eye(2))" ,"eye(3) + eye((2)","eye(3) + eye(20"
   ];

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
    printf("</p><hr>");

for expression_ in TestExpressions do
    printf(cat(expression_,"<br>"));
    Message:=CustomPreviewMatlab(expression_):
    printf(Message);
    printf("<hr>");
    
end do:

printf("");
printf("</body>\n</html>");

writeto(terminal);
