# This *.mpl file generates the HTML_examples.html file.
# This file contains a list of example outputs of the custom previewer.
# This is not perfect - some symbols in the MathML may not render properly - but can be used for quick sanity checks before uploading to Möbius for more comprehensive checks.

# Include the latest version of the Maple previewer library.
libname := libname,"MapleCustomPreviewer.mla";

# Suppress most output:
interface(quiet=true);

# Define a lists of test strings to pass through the previewer.

# For quick checks, add strings to the following list (move to one of the archive lists below when done).
# Always keep the empty string here.

quick_LIST := 
[
"int(x^2,x=0. .. .2)",
"a1.a2",
"1.2",
"1 . 2",
"[2(x)+1(x),1..1]",
"[int(x,x=1..1),p_1]",
"1/sqrt(2)",
"sqrt(201)(x)",
"sqrt(y+1)(x)"
];

create_MathML_LIST:=
[
"<a,b,c>"
,"1,2,<2,3>,[1,2]"
,"[1,2,<2,3>,[1,2]]"
,"<<a11,a21>|<a12,a22> >,<<b11,b21>|<b12,b22>>"
,"3*2+3*2"
,"3*(2+2)"
,"2+2"
,"exp(0)"
,"exp(x+2)"
,"(a+b)*c"
,"sqrt(x^2+1)"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(1)"
,"sinh(x)+cosh(t)"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(x/sqrt(8))"
,"5*x+8*y+7*z-16=0"
,"<1,2,0>+b*<2,1,-1>+c*<1,1,1>"
,"<1,2,0>+b*<2,1,-1>+c*<1,1.1>"
,"[1*2/(3*3)]"
,"2*<1,1,1>"
,"(a^b)^c"
,"a^(b^c)"
,"(1^2)^33"
,"2^(3^4)"
,"x^2+x"
,"Vector(3,{1=1,2=2,3=3})"
,"x->x^2+x"
,"a+b+c+d+c"
,"a+b+c+c=1"
,"<1,1,1>"
,"<1,1,sin(Pi)>"
,"ln(x)"
,"sin(Pi/6)"
,"Pi/6"
,"sin(Pi)"
,"sin(x)^2"
,"sqrt(x)"
,"8*x*ln(x^(2)+2)-16*x+16*sqrt(2)*arctan(x/sqrt(2))"
,"-1/10*(1+1/(5*x^2)) + (1/10)*(ln(1+1/(5*x^2)))"
,"12*sqrt(3)/Pi"
,"(sqrt(6)*(arctan(sqrt(6)*x)))/2"
,"6*x*ln(x^2+8)-12*x+(96/sqrt(8))*arctan(x/sqrt(8))"
,"-2+3*12*I*z"
,"3*I"
,"I*z*exp(1)"
,"(cos(-2)-cosh(-2))/(-2+4*I)"
,"infinity"
,"int(1/(1+x^4),x=-infinity..infinity)"
,"gamma*x"
,"Gamma*t"
,"Xi*t"
,"theta*x"
,"arcsin(x)"
,"eta*x"
,"gamma(x)"
,"Matrix(2, 2, [[a*x, 2*Pi], [cos(x), tan(1)*arctan(2)+3]])"
,"Vector[column](3, [1, 2, 3])"
,"Vector[row](5, [1, Pi, exp(5), cos(sqrt(x^2+3)), 2^exp(I)])"
,"3.1415*2.7183"
,".25343E-10"
,".000854e-15"
];

add_semantic_advice_LIST :=
[
"3*sqrt(101)(1-exp(-Pi/10))"
,"exp(pi)+e^(Pi)"
,"(2)(b)"
,"<1,1 ; 2 ,2 >"
,"<1,1*2/(3*3) ; 2 ,2 >"
,"[exp^x,sin-x,ln*x,cosh+1]"
,"x->x^2"
,"x->x^2;"
,"2*e+7*b+3*e"
,"e^x"
,"3(sin(x))"
,"In(x)"
,"2*pi*i"
,"infty"
,"Infinity"
,"infinitya"
,"int(xy/(1+x^4),x=-infinity..infinity)"
,"int(1/(1+x^4),x=-infinity..Infinity)"
,"integrate(1/(1+x^4),x=-inf..inf)"
,"uv"
,"xy"
,"tan(xy)"
,"(x,y)->xy"
,"gammax"
,"xgamma"
,"xtheta"
,"thetax"
,"sinx"
,"sin"
,"sin+arccos"
,"sin(cosx)"
,"sin(ax)"
,"xsin(x)"
,"xgamma(x)"
,"xf(x)"
,"Matrix(2, 2, [[a, cd], [b, xy]])"
,"f1(x)"
,"p1(x)+p2(x)"
,"1(x)"
];

add_syntax_advice_LIST := 
[
"ax+by+cz=d"
,"2/(-1"
,"2/-1"
,"2<1,1,1>"
,"a<1,1,1>"
,"(2)<1,1,1>"
,"f:=x->x^2;"
,"2a"
,"p1a(x)+-p2a(x)"
,"a^b^c"
];

optional_keyword_arguments_LIST :=
[
    [
        "ExpectedVariables accepts x",
        "x^2+Pi",
        "ExpectedVariables={x}",
        [ExpectedVariables={x}]
    ],
    [
        "ExpectedVariables accepts x",
        "xx^2+1",
        "ExpectedVariables={x}",
        [ExpectedVariables={x}]
    ],
    [
        "ExpectedVariables warns about y",
        "x^2+y",
        "ExpectedVariables={x}",
        [ExpectedVariables={x}]
    ],
    [
        "ExpectedVariables warns about y",
        "None",
        "ExpectedVariables={None,none}",
        [ExpectedVariables={None,none}]
    ],
    [
        "ExpectedVariables warns about y",
        "Noney",
        "ExpectedVariables={None,none}",
        [ExpectedVariables={None,none}]
    ],
    [
        "ExpectedVariables warns about p",
        "p1+p^2+p_3",
        "ExpectedVariables={p1,p2,p3}",
        [ExpectedVariables={p1,p2,p3}]
    ],
    [
        "ExpectedVariables with custom warning style",
        "x+y+z",
        "ExpectedVariables={x}, WarningStyle=\"color:#2000b0;font-weight:bold;\"",
        [ExpectedVariables={x}, WarningStyle="color:#2000b0;font-weight:bold;"]
    ],
    [
        "RawInputWarningProc",
        "x+1",
        "RawInputWarningProc=proc(inputString) return \"Custom raw-input warning.\"; end proc",
        [RawInputWarningProc=proc(inputString) return "Custom raw-input warning."; end proc]
    ],
    [
        "ResponseWarningProc",
        "x^2+1",
        "ResponseWarningProc=proc(response) return \"Custom parsed-expression warning.\"; end proc",
        [ResponseWarningProc=proc(response) return "Custom parsed-expression warning."; end proc]
    ],
    [
        "Combined optional warnings",
        "x+sin(y)",
        "ExpectedVariables={x}, ResponseWarningProc=proc(response) return \"Custom parsed-expression warning.\"; end proc, WarningStyle=\"color:#078d07;\"",
        [ExpectedVariables={x}, ResponseWarningProc=proc(response) return "Custom parsed-expression warning."; end proc, WarningStyle="color:#078d07;"]
    ]
];

# Identify the HTML file to write to (the old version should be in the folder already, ready to be overwritten).
writeto("HTML_examples.html");

# Add HTML preamble:
printf("<!DOCTYPE html>");
printf("<html>");
printf("<head>");
printf("  <meta charset=\"utf-8\">");
printf("  <title>Fullest MathML support using MathJax</title>");
printf("  <script>window.MathJax = { MathML: { extensions: [\"mml3.js\", \"content-mathml.js\"]}};</script>");
printf("<script type=\"text/javascript\" async src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=MML_HTMLorMML\"></script>");
printf("</head>\n\n<body>\n");

printf("<p style=\"text-align: center; color: #2b35ed; font-size:2.5em;\">Example Outputs of the UNSW M&ouml;bius Custom Previewer - Maple</p>");
printf("<p>Below are lists of example outputs of the custom previewer. Each input is stored as a string in <code>TestingThePreviewer.mpl</code> and, when the file is run via Maple, it produces this HTML file.</p>");
printf("<p>The function <code>testmyexpression</code> takes such a string input, and outputs a HTML snippet. In a M&ouml;bius where the custom previewer is uploaded, student inputs stored as <code>$RESPONSE</code> may be called by the following code (entered into the Custom Previewing Code field):</p>");
printf("<p><span style=\"font-family: Consolas, monospace;color:darkred\">&nbsp;Message:=testmyexpression(\"$RESPONSE\"); printf(\"%%s\",Message);</span></p>");
printf("<p>The output is what students see in M&ouml;bius when clicking the preview button. This HTML page contains many such outputs for testing purposes.</p>");
printf("<p>Note: This file is not perfect - some symbols in the MathML may not render properly - but it can be used for quick sanity checks before uploading the library file to Möbius for more comprehensive checks.</p>");
printf("<br>");

printf("<hr><details open><summary><span style=\"font-size:1.5em ;color: #188e00\">Quick checks</span>: <strong>New inputs for testing. Move to a list when done. (Always keep empty string here as a control.)</strong><hr></summary><p>");

# For each string in the sample list above, run the previewer and print the output.
for expression_ in quick_LIST do
    Message:=testmyexpression(expression_): printf("%s",Message);printf("</p><hr><p>");
end do:

printf("</p></details><hr><details><summary><span style=\"font-size:1.5em; font-family: Consolas, monospace;color: #8d0707\">create_MathML</span>: <strong>Inputs contain no syntax errors or potential mistakes, and <code>add_semantic_advice</code> should concatenate no advice.</strong><hr></summary><p>");

# For each string in the sample list above, run the previewer and print the output.
for expression_ in create_MathML_LIST do
    Message:=testmyexpression(expression_): printf("%s",Message);printf("</p><hr><p>");
end do:

printf("</p></details><details><summary><span style=\"font-size:1.5em; font-family: Consolas, monospace;color: #8d0707\">add_semantic_advice</span>: <strong>Inputs are parsable by Maple, but may contain problems we want to flag with students via <code>add_semantic_advice</code>. Calling <code>create_MathML</code> may fail.</strong><hr></summary><p>");

# For each string in the sample list above, run the previewer and print the output.
for expression_ in add_semantic_advice_LIST do
    Message:=testmyexpression(expression_):printf("%s",Message);printf("</p><hr><p>");
end do:

printf("</p></details><details><summary><span style=\"font-size:1.5em; font-family: Consolas, monospace;color: #8d0707\">add_syntax_advice</span>: <strong>Input throws at least one error upon parsing.</strong><hr></summary><p>");

# For each string in the sample list above, run the previewer and print the output.
for expression_ in add_syntax_advice_LIST do
    Message:=testmyexpression(expression_):printf("%s",Message);printf("</p><hr><p>");
end do:

printf("</p></details><details><summary><span style=\"font-size:1.5em; font-family: Consolas, monospace;color: #8d0707\">optional keyword arguments</span>: <strong>Inputs call <code>testmyexpression</code> with extra keyword arguments.</strong><hr></summary>");
printf("<table style=\"border-collapse: collapse; width:100%;\">");
printf("<thead><tr>");
printf("<th style=\"border:1px solid #888; padding:0.4em; text-align:left;\">Test</th>");
printf("<th style=\"border:1px solid #888; padding:0.4em; text-align:left;\">Input</th>");
printf("<th style=\"border:1px solid #888; padding:0.4em; text-align:left;\">Keyword arguments</th>");
printf("</tr></thead><tbody>");

# For each row, call the previewer with the keyword arguments stored in the fourth entry.
for optional_keyword_arguments_ROW in optional_keyword_arguments_LIST do
    test_label_:=optional_keyword_arguments_ROW[1]:
    expression_:=optional_keyword_arguments_ROW[2]:
    keyword_arguments_display_:=optional_keyword_arguments_ROW[3]:
    keyword_arguments_:=optional_keyword_arguments_ROW[4]:

    printf("<tr>");
    printf("<td style=\"border:1px solid #888; padding:0.4em;\"><strong>%s</strong></td>",StringTools:-Escape(test_label_,'html'));
    printf("<td style=\"border:1px solid #888; padding:0.4em;\"><code>%s</code></td>",StringTools:-Escape(expression_,'html'));
    printf("<td style=\"border:1px solid #888; padding:0.4em;\"><code>%s</code></td>",StringTools:-Escape(keyword_arguments_display_,'html'));
    printf("</tr>");
    printf("<tr><td colspan=\"3\" style=\"border:1px solid #888; padding:0.4em;\">");
    Message:=testmyexpression(expression_,op(keyword_arguments_)):printf("%s",Message);
    printf("</td></tr>");
end do:

printf("</tbody></table></details><p>");

# Add HTML postscript:
printf("</p>");
printf("</body>\n</html>");

# Return to normal terminal output.
writeto(terminal);



