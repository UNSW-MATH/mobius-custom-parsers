# This *.mpl file compares a saved previewer expected-output snapshot with the latest MapleCustomPreviewer.mla.
#
# Typical local use:
#   maple -q
#   read("ComparePreviewerExpectedOutputs.mpl"):
#   ComparePreviewerExpectedOutputs("testing/PreviewerExpectedOutputs_1_0_5_warning_proc_test.mpl"):
#
# Or, as a one-off shell command from this directory:
#   ./run_compare.sh PreviewerExpectedOutputs_1_0_5_warning_proc_test.mpl

# Include the latest version of the Maple previewer library.
libname := libname,"MapleCustomPreviewer.mla";

# Suppress most output:
interface(quiet=true);

# These may be assigned before reading this file.
if not assigned('ComparePreviewerExpectedOutputsFilename') then
    ComparePreviewerExpectedOutputsFilename := NULL:
end if:

if not assigned('ComparePreviewerComparisonFilename') then
    ComparePreviewerComparisonFilename := NULL:
end if:

PreviewerComparisonVersionName := proc(versionString) local versionName;
    versionName:=versionString;
    versionName:=StringTools:-RegSubs("[ .]" = "_",versionName);
    versionName:=StringTools:-RegSubs("[^A-Za-z0-9_-]" = "",versionName);
    return versionName;
end proc:

PreviewerComparisonHTMLEscape := proc(inputString);
    return StringTools:-Escape(inputString,'html');
end proc:

PreviewerComparisonNormalizeOutput := proc(outputString) local previewerSignaturePattern;
    previewerSignaturePattern := "<p[^>]*>UNSW M&ouml;bius Custom Previewer v[^<]*</p>";
    return StringTools:-RegSubs(previewerSignaturePattern = "",outputString);
end proc:

PreviewerComparisonSnapshotString := proc(snapshotValue,fieldName,exampleNumber);
    if type(snapshotValue,string) then
        return snapshotValue;
    end if;

    error "Expected %1 for example %2 to be stored as a string, but found %3",fieldName,exampleNumber,whattype(snapshotValue);
end proc:

PreviewerComparisonDefaultOutputFilename := proc(expectedVersion,currentVersion)
    return cat(
        "testing/PreviewerComparison_",
        PreviewerComparisonVersionName(expectedVersion),
        "_against_",
        PreviewerComparisonVersionName(currentVersion),
        ".html"
    );
end proc:

ComparePreviewerExpectedOutputs := proc(
    expectedOutputsFilename,
    {OutputFilename := NULL}
) local
    outputFilename,
    currentVersion,
    expectedVersion,
    totalCount,
    changedExamples,
    ii,
    exampleRecord,
    suiteName,
    inputString,
    expectedOutput,
    actualOutput,
    normalizedExpectedOutput,
    normalizedActualOutput,
    changedRecord;
    global
        PreviewerExpectedOutputs,
        PreviewerExpectedOutputsVersion,
        PreviewerExpectedOutputsGeneratedAt;

    if expectedOutputsFilename = NULL or not type(expectedOutputsFilename,string) or expectedOutputsFilename = "" then
        error "Set ComparePreviewerExpectedOutputsFilename to an expected-output snapshot filename before reading this file.";
    end if;

    if not FileTools:-Exists(expectedOutputsFilename) then
        error "Expected-output snapshot %1 does not exist.",expectedOutputsFilename;
    end if;

    PreviewerExpectedOutputs:='PreviewerExpectedOutputs':
    PreviewerExpectedOutputsVersion:='PreviewerExpectedOutputsVersion':
    PreviewerExpectedOutputsGeneratedAt:='PreviewerExpectedOutputsGeneratedAt':

    read(expectedOutputsFilename);

    if not assigned('PreviewerExpectedOutputs') then
        error "Expected-output snapshot %1 did not define PreviewerExpectedOutputs.",expectedOutputsFilename;
    end if;

    if not assigned('PreviewerExpectedOutputsVersion') then
        PreviewerExpectedOutputsVersion := "unknown":
    end if:

    currentVersion:=MaplePreviewerVersion();
    expectedVersion:=PreviewerExpectedOutputsVersion;

    if OutputFilename = NULL then
        if not FileTools:-Exists("testing") then
            FileTools:-MakeDirectory("testing");
        end if;

        outputFilename:=PreviewerComparisonDefaultOutputFilename(expectedVersion,currentVersion);
    else
        outputFilename:=OutputFilename;
    end if;

    totalCount:=nops(PreviewerExpectedOutputs);
    changedExamples:=[];

    for ii to totalCount do
        exampleRecord:=PreviewerExpectedOutputs[ii];
        if nops(exampleRecord) <> 3 then
            error "Expected example %1 to have the form [suite_name, input_string, expected_output_string].",ii;
        end if;

        suiteName:=PreviewerComparisonSnapshotString(exampleRecord[1],"suite_name",ii);
        inputString:=PreviewerComparisonSnapshotString(exampleRecord[2],"input_string",ii);
        expectedOutput:=PreviewerComparisonSnapshotString(exampleRecord[3],"expected_output_string",ii);
        actualOutput:=testmyexpression(inputString);
        normalizedExpectedOutput:=PreviewerComparisonNormalizeOutput(expectedOutput);
        normalizedActualOutput:=PreviewerComparisonNormalizeOutput(actualOutput);

        if normalizedActualOutput <> normalizedExpectedOutput then
            changedRecord:=[
                ii,
                suiteName,
                inputString,
                expectedOutput,
                actualOutput,
                normalizedExpectedOutput,
                normalizedActualOutput
            ];
            changedExamples:=[op(changedExamples),changedRecord];
        end if;
    end do;

    writeto(outputFilename);
    printf("<!DOCTYPE html>\n");
    printf("<html>\n");
    printf("<head>\n");
    printf("  <meta charset=\"utf-8\">\n");
    printf("  <title>Maple Previewer Comparison</title>\n");
    printf("  <script>window.MathJax = { MathML: { extensions: [\"mml3.js\", \"content-mathml.js\"]}};</script>\n");
    printf("  <script type=\"text/javascript\" async src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=MML_HTMLorMML\"></script>\n");
    printf("  <style>\n");
    printf("    body { font-family: Arial, sans-serif; margin: 24px; color: #222; }\n");
    printf("    h1 { font-size: 1.7em; margin-bottom: 0.2em; }\n");
    printf("    code, pre { font-family: Consolas, monospace; }\n");
    printf("    .summary { margin: 16px 0 24px; padding: 12px; border-left: 4px solid #8d0707; background: #fff4f4; }\n");
    printf("    .example { border-top: 1px solid #bbb; padding: 18px 0; }\n");
    printf("    .comparison-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; align-items: start; }\n");
    printf("    .panel { border: 1px solid #ccc; padding: 12px; overflow-x: auto; }\n");
    printf("    .panel h3 { margin-top: 0; }\n");
    printf("    pre { white-space: pre-wrap; overflow-x: auto; background: #f7f7f7; padding: 8px; }\n");
    printf("    .diff-code mark { border-radius: 2px; padding: 0 1px; }\n");
    printf("    .diff-removed { background: #ffe2e2; color: #8d0707; }\n");
    printf("    .diff-added { background: #dcfce7; color: #14532d; }\n");
    printf("    @media (max-width: 900px) { .comparison-grid { grid-template-columns: 1fr; } }\n");
    printf("  </style>\n");
    printf("  <script>\n");
    printf("    document.addEventListener('DOMContentLoaded', function () {\n");
    printf("      function escapeHtml(text) {\n");
    printf("        return text\n");
    printf("          .replace(/&/g, '&amp;')\n");
    printf("          .replace(/</g, '&lt;')\n");
    printf("          .replace(/>/g, '&gt;')\n");
    printf("          .replace(/\"/g, '&quot;')\n");
    printf("          .replace(/'/g, '&#39;');\n");
    printf("      }\n");
    printf("\n");
    printf("      function tokenizeHtml(text) {\n");
    printf("        return text.match(/<\\/?[^>]+>|&[A-Za-z0-9#]+;|\\s+|[A-Za-z0-9_:-]+|./g) || [];\n");
    printf("      }\n");
    printf("\n");
    printf("      function marked(className, token) {\n");
    printf("        return '<mark class=\"' + className + '\">' + escapeHtml(token) + '</mark>';\n");
    printf("      }\n");
    printf("\n");
    printf("      function diffTokens(expectedTokens, actualTokens) {\n");
    printf("        var n = expectedTokens.length;\n");
    printf("        var m = actualTokens.length;\n");
    printf("        var table = [];\n");
    printf("        var i;\n");
    printf("        var j;\n");
    printf("        for (i = 0; i <= n; i += 1) {\n");
    printf("          table[i] = Array(m + 1).fill(0);\n");
    printf("        }\n");
    printf("        for (i = n - 1; i >= 0; i -= 1) {\n");
    printf("          for (j = m - 1; j >= 0; j -= 1) {\n");
    printf("            if (expectedTokens[i] === actualTokens[j]) {\n");
    printf("              table[i][j] = table[i + 1][j + 1] + 1;\n");
    printf("            } else {\n");
    printf("              table[i][j] = Math.max(table[i + 1][j], table[i][j + 1]);\n");
    printf("            }\n");
    printf("          }\n");
    printf("        }\n");
    printf("\n");
    printf("        var expectedHtml = '';\n");
    printf("        var actualHtml = '';\n");
    printf("        i = 0;\n");
    printf("        j = 0;\n");
    printf("        while (i < n && j < m) {\n");
    printf("          if (expectedTokens[i] === actualTokens[j]) {\n");
    printf("            expectedHtml += escapeHtml(expectedTokens[i]);\n");
    printf("            actualHtml += escapeHtml(actualTokens[j]);\n");
    printf("            i += 1;\n");
    printf("            j += 1;\n");
    printf("          } else if (table[i + 1][j] >= table[i][j + 1]) {\n");
    printf("            expectedHtml += marked('diff-removed', expectedTokens[i]);\n");
    printf("            i += 1;\n");
    printf("          } else {\n");
    printf("            actualHtml += marked('diff-added', actualTokens[j]);\n");
    printf("            j += 1;\n");
    printf("          }\n");
    printf("        }\n");
    printf("        while (i < n) {\n");
    printf("          expectedHtml += marked('diff-removed', expectedTokens[i]);\n");
    printf("          i += 1;\n");
    printf("        }\n");
    printf("        while (j < m) {\n");
    printf("          actualHtml += marked('diff-added', actualTokens[j]);\n");
    printf("          j += 1;\n");
    printf("        }\n");
    printf("        return [expectedHtml, actualHtml];\n");
    printf("      }\n");
    printf("\n");
    printf("      document.querySelectorAll('.diff-pair').forEach(function (pair) {\n");
    printf("        var expected = pair.querySelector('.diff-expected');\n");
    printf("        var actual = pair.querySelector('.diff-actual');\n");
    printf("        var highlighted = diffTokens(tokenizeHtml(expected.textContent), tokenizeHtml(actual.textContent));\n");
    printf("        expected.innerHTML = highlighted[0];\n");
    printf("        actual.innerHTML = highlighted[1];\n");
    printf("      });\n");
    printf("    });\n");
    printf("  </script>\n");
    printf("</head>\n");
    printf("<body>\n");
    printf("<h1>Maple Previewer Comparison</h1>\n");
    printf("<div class=\"summary\">\n");
    printf("<p><strong>Expected-output snapshot:</strong> <code>%s</code></p>\n",PreviewerComparisonHTMLEscape(expectedOutputsFilename));
    printf("<p><strong>Expected version:</strong> %s</p>\n",PreviewerComparisonHTMLEscape(expectedVersion));
    printf("<p><strong>Latest library version:</strong> %s</p>\n",PreviewerComparisonHTMLEscape(currentVersion));
    printf("<p><strong>Normalization:</strong> Previewer version/contact footer omitted.</p>\n");
    printf("<p><strong>Changed examples:</strong> %d of %d</p>\n",nops(changedExamples),totalCount);
    printf("</div>\n");

    if nops(changedExamples) = 0 then
        printf("<p>No changed examples found.</p>\n");
    else
        for changedRecord in changedExamples do
            printf("<div class=\"example\">\n");
            printf("<h2>Example %d: %s</h2>\n",changedRecord[1],PreviewerComparisonHTMLEscape(changedRecord[2]));
            printf("<p><strong>Input:</strong> <code>%s</code></p>\n",PreviewerComparisonHTMLEscape(changedRecord[3]));
            printf("<div class=\"comparison-grid\">\n");
            printf("<div class=\"panel\"><h3>Expected</h3>%s</div>\n",changedRecord[4]);
            printf("<div class=\"panel\"><h3>Actual</h3>%s</div>\n",changedRecord[5]);
            printf("</div>\n");
            printf("<div class=\"diff-pair\">\n");
            printf("<details><summary>Normalised expected HTML</summary><pre class=\"diff-code diff-expected\">%s</pre></details>\n",PreviewerComparisonHTMLEscape(changedRecord[6]));
            printf("<details><summary>Normalised actual HTML</summary><pre class=\"diff-code diff-actual\">%s</pre></details>\n",PreviewerComparisonHTMLEscape(changedRecord[7]));
            printf("</div>\n");
            printf("</div>\n");
        end do;
    end if;

    printf("</body>\n");
    printf("</html>\n");
    writeto(terminal);

    printf("%d of %d examples changed.\n",nops(changedExamples),totalCount);
    printf("Comparison HTML written to %s\n",outputFilename);

    return changedExamples;
end proc:

if ComparePreviewerExpectedOutputsFilename = NULL or not type(ComparePreviewerExpectedOutputsFilename,string) or ComparePreviewerExpectedOutputsFilename = "" then
    NULL:
elif ComparePreviewerComparisonFilename = NULL then
    ComparePreviewerExpectedOutputs(ComparePreviewerExpectedOutputsFilename):
else
    ComparePreviewerExpectedOutputs(ComparePreviewerExpectedOutputsFilename,OutputFilename=ComparePreviewerComparisonFilename):
end if:
