# Mobius Custom Parsers and UNSW core extensions

These libraries are used by the School of Mathematics and Statistics, 
UNSW Sydney. These libraries are in constant state of development and provided
AS IS WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.

## Personalised Feedback

A library to help simplify the process of adding personalised feedback. Read more complete documentation [here](./ExtensionLibraries/PersonalisedFeedback/README.md).

## Maple Parser

A library for enhancing the default previewer. Read more complete documentation [here](./Maple/docs/README.md).

## Matlab Parser

A library for parsing and previewing responses entered in Matlab syntax. Read more complete documentation [here](./Matlab/docs/README.md).

# Known Issues with libraries/Maple repositories

## Answers cannot begin with a hyphen (issue MO-9897)

Because of the way the libname variable is set and concatenated with user input
the correct answer cannot start with a hyphen as this combines with a terminating colon
to create the character sequence `:-` 
(The [binary member selection operator](https://www.maplesoft.com/support/help/view.aspx?path=colondash)).

Adding space before an answer does not work (suggesting spaces are trimmed off), 
so the recommending workaround until this is fixed is to surround the answer with parentheses.