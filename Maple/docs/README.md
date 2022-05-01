# Mobius Custom Maple Parser

## Maple Parser

The Mobius custom Maple parser is designed to preview a student
response in as an inert form as is possible the `InertForm` package
in Maple is use to acheive this, but care must be take if we want to
avoid avoid processing expression like `2^3` and `sin(Pi)`.

Matrices also don't seem to display correct after a trip through the 
`InertForm` package, so a separate solution is devised for those.

## Error types

### Syntax errors

Students will often enter expression that are syntaxically incorrect. 
For example `1/-2` and `2x`. The can be caught as exceptions and 
reported back to the user.

### Semantics errors

Students will also often enter answers which are syntaxically correct, 
but have a different semantic meaning from what was intended. For example,
the expression `2(sin(x))` is valid Maple syntax, but really means the 
constant `2`, instead of likely inteded `2*sin(x)`.

These sort of issues must be searched for using custom techniques and 
reported back as they are found.

## How to implement this custom parser in a question

To use this the `.lib` and `.ind` files must be uploaded to the files
and the `.lib` file must be linked to via the 'Maple Repository' section
of a Maple Graded response area. The following code added to the 
Custom Previewing Code:

    Message:=testmyexpression("$RESPONSE"); 
    printf(Message);
