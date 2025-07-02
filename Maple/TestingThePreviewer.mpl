libname := libname,"MapleCustomPreviewer.lib";

interface(quiet=true);

list_of_expressions_to_test:=
[""
,"[ < < a11, a21 > | < a12, a22 > >, < < b11, b21 > | < b12, b22 > > ]"
,"3*sqrt(101)(1-exp(-Pi/10))"
,"3*2+3*2"
,"3*(2+2)"
,"exp(pi)+e^(Pi)"
,"2+2"
,"exp(0)"
,"exp(x+2)"
,"(a+b)*c"
,"sqrt(x^2+1)"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(1)"
,"sinh(x)+cosh(t)"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(x/sqrt(8))"
,"5*x+8*y+7*z-16=0"
,"ax+by+cz=d"
,"<1,2,0>+b*<2,1,-1>+c*<1,1,1>"
,"<1,2,0>+b*<2,1,-1>+c*<1,1.1>"
,"2/(-1"
,"2/-1"
,"(2)(b)"
,"[1*2/(3*3)]"
,"<1,1 ; 2 ,2 >"
,"<1,1*2/(3*3) ; 2 ,2 >"
,"2*<1,1,1>"
,"2<1,1,1>"
,"a<1,1,1>"
,"(2)<1,1,1>"
,"[exp^x,sin-x,ln*x,cosh+1]"
,"f:=x->x^2;"
,"x->x^2;"
,"2a"
,"a^b^c"
,"(a^b)^c"
,"a^(b^c)"
,"(1^2)^33"
,"2^(3^4)"
,"x^2+x"
,"Vector(3,{1=1,2=2,3=3})"
,"x->x^2+x"
,"a+b+c+d+c"
,"a+b+c+c=1"
,"2a"
,"2*e+7*b+3*e"
,"e^x"
,"3(sin(x))"
,"<1,1,1>"
,"<1,1,sin(Pi)>"
,"ln(x)"
,"In(x)"
,"In(x)"
,"sin(Pi/6)"
,"Pi/6"
,"sin(Pi)"
,"sin(x)^2"
,"sqrt(x)"
,"8*x*ln(x^(2)+2)-16*x+16*sqrt(2)*arctan(x/sqrt(2))"
,"-1/10*(1+1/(5*x^2)) + (1/10)*(ln(1+1/(5*x^2)))"
,"12*sqrt(3)/Pi"
,"(sqrt(6)*(arctan(sqrt(6)*x)))/2"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(x/sqrt(8))"];

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
printf("</p><hr><p>");


for expression_ in list_of_expressions_to_test do
    Message:=testmyexpression(expression_):printf("%s",Message);printf("</p><hr><p>");
end do:


printf("</p>");
printf("</body>\n</html>");

writeto(terminal);



