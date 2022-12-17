# Matlab Parser and Previwer

This library builds on the Matlab package in Maple to 
create a parser and previewing for the Mobius platform.

The package provides two basic commands
 - `MatlabExpressionParse`
 - `CustomPreviewMatlab`

## Parser

To use the custom parser you just use

    MatlabExpressionParse("$RESPONSE")

This will parse the expression, correcting for [known errors in the FromMatlab command](KnownErrorsInFromMatlab.md), and return a Maple object.

## Previewer
To use add the following to the Custom Preview:
     
    Message := CustomPreviewMatlab("$RESPONSE"); printf("%s",Message);