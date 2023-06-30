# Matlab Parser and Previwer

This library builds on the Matlab package in Maple to 
create a parser and previewing for the Mobius platform.

The package provides two basic commands
 - `MatlabExpressionParse`
 - `CustomPreviewMatlab`


## Parser

To use the custom parser you just use

    MatlabExpressionParse("$RESPONSE")

This will parse the expression, correcting for [known issues in the FromMatlab command](KnownIssuesInFromMatlab.md), and return a Maple object.


## Previewer
To use add the following to the Custom Preview:
     
    Message := CustomPreviewMatlab("$RESPONSE"); printf("%s",Message);

If the the expression was writen in correct Matlab syntax then this
should preview their expression. If the expression returns a known Matlab 
syntax error it will try to report this in the preview.

If an unknown error occurs this is provided in the preview with a warning
that the previewer cannot be relied on this in case.


## Building the library

Running the file `Matlab/matlab_previewer.mpl` using Maple will generate the files:

- PreviewMatlabExpression.ind
- PreviewMatlabExpression.lib
- PreviewMatlabMatrix.ind
- PreviewMatlabMatrix.lib

You can combine these into a single `.zip` file and upload them to Mobius in one step. Please note that you probably need to delete the `.ind` and `.lib` files if you are running genrating the files a second time.