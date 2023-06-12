PersonalisedFeedback_KeywordArguments := proc({correctAnswerString::string:=NULL
                             ,feedbackProc::procedure():=NULL
                             ,feedbackArgs::list():=[]})
    local MessageAsHTML,FormattedFeedback;

    MessageAsHTML:=""; 
    try:
        MessageAsHTML := feedbackProc(_rest);
        if StringTools[DeleteSpace](MessageAsHTML) <> "" then
           FormattedFeedback:= sprintf(`<br></td></tr><tr><th colspan="4" width="50%%">Feedback: </th></tr><tr><td colspan="4" class="part-answer" width="50%%">%s`,MessageAsHTML);
        else
           FormattedFeedback:="";
        end if;
        
    return cat(sprintf("%s",correctAnswerString),FormattedFeedback);
    catch:
    end try: 

    return correctAnswerString;

end proc:

PersonalisedFeedback:=overload([
    proc(a::string,b::string) option overload;
        return PersonalisedFeedback_KeywordArguments(
             correctAnswerString=a
            ,feedbackProc= (x->b)
            ,_rest)
    end proc

   ,proc(a::string,b::procedure) option overload;
        return PersonalisedFeedback_KeywordArguments(
             correctAnswerString=a
            ,feedbackProc=b 
            ,_rest)
    end proc

   ,PersonalisedFeedback_KeywordArguments
]):


library_name_list:=
[
     "0.0.0"
];

library_name_list:=
    map(xx->StringTools:-SubstituteAll(xx,".","_"),library_name_list);

librarynames:=map2(cat,"PersonalisedFeedback_",library_name_list,".lib");

for ii in [op(librarynames),"PersonalisedFeedback.lib"] do
    march('create',ii):
    savelib('PersonalisedFeedback',ii);
    savelib('PersonalisedFeedback_KeywordArguments',ii);
end do;
