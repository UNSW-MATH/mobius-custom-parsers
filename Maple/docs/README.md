# Mobius Custom Maple Parser

This library was the first library written in this repository and
should be re-written using the techniques learnt from writing the
other libraries.

## Maple Parser

The Mobius custom Maple parser is designed to preview a student
response in an inert form using Maple's `InertForm` package, and to 
provide syntax advice where possible.

Many tricks are employed to avoid processing expression 
like `2^3` and `sin(Pi)` into `8` and `0` respectively.

Matrices also don't seem to display correct after a trip through the 
`InertForm` package, so a separate solution was devised for those.

## Error types

### Syntax errors

Students will often enter expression that are syntaxically incorrect. 
For example `1/-2` and `2x`. The can be caught as exceptions and 
reported back to the user.

### Semantics errors

Students will also often enter answers which are syntaxically correct, 
but have a different semantic meaning from what was intended. For example,
the expression `2(sin(x))` is valid Maple syntax, but is understood as the
constant `2`, instead of likely intended `2*sin(x)`.

These sort of issues must be searched for using custom techniques and 
reported back as they are found.

## How to implement this custom parser in a question

To use this the `.lib` and `.ind` files must be uploaded to the files
and the `.lib` file must be linked to via the 'Maple Repository' section
of a Maple Graded response area. The following code added to the 
Custom Previewing Code:

    Message:=testmyexpression("$RESPONSE"); 
    printf("%s",Message);

## Testing output and Comparing saved previewer output

`TestingThePreviewer.mpl` contains the example inputs used for the previewer sanity checks. Its suites cover quick checks, MathML creation, semantic advice, and syntax advice. Running the file creates `HTML_examples.html`, a page showing the previewed examples, and saves their output as a versioned snapshot in `testing/PreviewerExpectedOutputs_<version>.mpl`.

Snapshots are a useful for checking changes to the previewer. By default a new snapshot is created when previewer test are run, to disable this set `SaveExpectedOutputs := false` in `TestingThePreviewer.mpl`. The snapshot records the previewer version and generation time, plus each suite name, input string, and generated HTML. Pre-existing snapshots are protected, meaning that saving fails if the target file already exists. This can be overwridden by setting `OverwriteExpectedOutputs := true`, but it is safer just to delete this snapshot to avoid accidentally overwritting this in the future.

To compare a snapshot against the current `MapleCustomPreviewer.mla`, run the script `./run_compare` from any directory, for example

    ./run_compare.sh testing/PreviewerExpectedOutputs_1_0_5.mpl

The script runs from the `Maple` directory and looks for a file under `Maple/testing/`. You can also pass a path, for example `./Maple/run_compare.sh testing/PreviewerExpectedOutputs_1_0_6.mpl` when already in `Maple`. The software Maple must be installed and available as `maple` on `PATH`.

For interactive use from the `Maple` directory, the equivalent Maple commands are:

    read("ComparePreviewerExpectedOutputs.mpl"):
    ComparePreviewerExpectedOutputs("testing/PreviewerExpectedOutputs_1_0_6.mpl"):

The comparison command loads the latest previewer library, reads each saved input through `testmyexpression`, and writes an HTML report. By default the report is named `testing/PreviewerComparison_<expected-version>_against_<current-version>.html`. Set `OutputFilename="path/to/report.html"` to choose another path. The report summarizes the changed examples and includes the expected and current HTML for inspection. It compares exact generated output after removing the embedded previewer version signature, since that signature is expected to differ when versions change. 
