# Personalised Feedback

This library provide a commands `PersonalisedFeedback`.

To use this you can put the following code in the Answer field

    Message:=PersonalisedFeedback("$YourAnswer",feedbackProc,"$RESPONSE")

where `feedbackProc` is a procedure written to process the student `$RESPONSE` 
and provide custom feedback.

If no feedback is provided only the `$YourAnswer` will be displayed to the 
student, otherwise your answer is displayed and HTML will be added to prematurely
close the table row and add two additional row.

This is somewhat dodgy, but an advantage to using a library to do this is
that it can be easily updated if the gradebook view changes significantly.