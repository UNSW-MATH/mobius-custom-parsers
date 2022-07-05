
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
   ,"1/12*(sin(x))^12-2/10*(sin(x))^10+1/8*(sin(x))^8"
   ,"-2*i"
   ,"6 - 2*exp(1)"
   ,"x^(-1/2)"
   ,"2/5*x^3 + C*sqrt(x)"
   ,"-3 + 4i"
   ,"1/2*(sin(10*x)+sin(-4*x))"
   ,"1/(sqrt(x))"
   ,"(sin(x))^7/7-(sin(x))^9/9"
   ,"exp(-2*log(x)) "
   ,"(x^5/5+C)/exp(-2*log(x)) "
   ,"(720-1956*exp(-1))/6 "
   ,"1/3 *sin(x)^3 - 1/5 *sin(x)^5 "
   ,"25*r^2 -10*r+17 "  
   ,"exp([1,1;2,2])"
   ,"1++1","[1 ++2]","[1 + +2]","[1 --3i]'"
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
