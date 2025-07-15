MatlabPreviewerVersion := proc() return "1.0.0" end proc;

displayMatlabVersionNumber:=proc(inputString)
    VersionNumber:=MatlabPreviewerVersion():
    versionMessage:=sprintf("<p style=\"text-align: right;color: #12b0fd;\" title=\"Contact Joshua Capel (j.capel@unsw.edu.au) to report errors.\">UNSW M&ouml;bius Matlab Previewer v%s</p>",VersionNumber):

    return cat(inputString,versionMessage):
end proc;

CustomMatlabCompatibility := module() option package; 
        _export(MatrixApply
               ,sin_MATLAB  ,cos_MATLAB  ,tan_MATLAB  ,sec_MATLAB  ,cot_MATLAB
               ,arcsin_MATLAB ,arccos_MATLAB ,arctan_MATLAB ,arcsec_MATLAB ,arccot_MATLAB
               
               ,sinh_MATLAB ,cosh_MATLAB ,tanh_MATLAB ,sech_MATLAB ,coth_MATLAB
               ,arcsinh_MATLAB,arccosh_MATLAB,arctanh_MATLAB,arcsech_MATLAB,arccoth_MATLAB
               
               ,exp_MATLAB,ln_MATLAB
               ,sqrt_MATLAB

               ,`.`
               ,`~`);

     MatrixApply := proc(f,a)
         if type(a,Matrix) or type(a,Vector) then
            map(f,a);
         else
            f(a)
         end if;
     end proc;

     `.` := proc(x,y)
          if type(x,algebraic) or type(y,algebraic) then
             if _nrest > 0 then
                 return `.`(x*y,_rest)
             else
                 return x*y
             end if;
          else
             if _nrest > 0 then
                 return `.`(:-`.`(x,y),_rest)
             else
                 return :-`.`(x,y)
             end if;
          end if;
     end proc;
     
     `~` := proc(x,sep,y) local x1,x2,y1,y2;
         local newargs, operation, i;
         operation := op(procname);
       
        (* Replicate Matlab's Array broadcasting for Arrays. Dimesions of Arrays
           are the same, or 1, then addition can occur. 
           
           Only implemented for 2D arrays here. *)
         if operation = `+` or operation = `-` then 
             x1:=ArrayTools:-Size(x)[1]; x2:=ArrayTools:-Size(x)[2];
             y1:=ArrayTools:-Size(y)[1]; y2:=ArrayTools:-Size(y)[2];
           
             # Assume a good state until provent otherwise
             replicateNeeded:=true;  replicatePlan:=[1,1,1,1]:

             if x1 = y1 then 
                # Do nothing, already compatible
             elif x1 = 1 and y1 > 1 then
                #Plan to replicate the first dimesion in the first array
                replicatePlan[1]:=y1: 
             elif x1 > 1 and y1 = 1 then
                #Plan to replicate the first dimesion in the second array
                replicatePlan[3]:=x1:
             else
                # First dimension is not compatible with addition
                replicateNeeded:=false;
                error "Arrays have incompatible sizes for this operation.";
             end if;

             if x2 = y2 then 
                # Do nothing, already compatible
             elif x2 = 1 and y2 > 1 then
                #Plan to replicate the second dimesion in the first array
                replicatePlan[2]:=y2: 
             elif x2 > 1 and y2 = 1 then
                #Plan to replicate the second dimesion in the second array
                replicatePlan[4]:=x2:
             else
                # Second dimension is not compatible with addition
                replicateNeeded:=false;
                error "Arrays have incompatible sizes for this operation.";
             end if;

             if replicateNeeded and max(x1,x2,y1,y2) > 1 then
                 return :-`~`[operation](ArrayTools:-Replicate(<x>,replicatePlan[1],replicatePlan[2])
                                        ,ArrayTools:-Replicate(<y>,replicatePlan[3],replicatePlan[4]));
             end if;
         end if; 

         newargs := _passed;
         return :-`~`[operation](newargs);
     end;

  
     exp_MATLAB := proc(a) MatrixApply(:-`exp`,a) end proc;
     ln_MATLAB  := proc(a) MatrixApply(:-`log`,a) end proc;
     sqrt_MATLAB  := proc(a) MatrixApply(:-`sqrt`,a) end proc;
     
            
     sin_MATLAB := proc(a) MatrixApply(:-`sin`,a) end proc;
     cos_MATLAB := proc(a) MatrixApply(:-`cos`,a) end proc;
     tan_MATLAB := proc(a) MatrixApply(:-`tan`,a) end proc;
     sec_MATLAB := proc(a) MatrixApply(:-`sec`,a) end proc;
     cot_MATLAB := proc(a) MatrixApply(:-`cot`,a) end proc;
     
     arcsin_MATLAB := proc(a) MatrixApply(:-`arcsin`,a) end proc;
     arccos_MATLAB := proc(a) MatrixApply(:-`arccos`,a) end proc;
     arctan_MATLAB := proc(a) MatrixApply(:-`arctan`,a) end proc;
     arcsec_MATLAB := proc(a) MatrixApply(:-`arcsec`,a) end proc;
     arccot_MATLAB := proc(a) MatrixApply(:-`arccot`,a) end proc;
     
     sinh_MATLAB := proc(a) MatrixApply(:-`sinh`,a) end proc;
     cosh_MATLAB := proc(a) MatrixApply(:-`cosh`,a) end proc;
     tanh_MATLAB := proc(a) MatrixApply(:-`tanh`,a) end proc;
     sech_MATLAB := proc(a) MatrixApply(:-`sech`,a) end proc;
     coth_MATLAB := proc(a) MatrixApply(:-`coth`,a) end proc;
     
     arcsinh_MATLAB := proc(a) MatrixApply(:-`arcsinh`,a) end proc;
     arccosh_MATLAB := proc(a) MatrixApply(:-`arccosh`,a) end proc;
     arctanh_MATLAB := proc(a) MatrixApply(:-`arctanh`,a) end proc;
     arcsech_MATLAB := proc(a) MatrixApply(:-`arcsech`,a) end proc;
     arccoth_MATLAB := proc(a) MatrixApply(:-`arccoth`,a) end proc;
     
end module:


matlab_function_replacement_list := [["asin","arcsin"]
                                    ,["acos","arccos"]
                                    ,["atan","arctan"]
                                    ,["asec","arcsec"]
                                    ,["acsc","arccsc"]
                                    ,["acot","arccot"]
                                    ,["asinh","arcsinh"]
                                    ,["acosh","arccosh"]
                                    ,["atanh","arctanh"]
                                    ,["asech","arcsinh"]
                                    ,["acsch","arccsch"]
                                    ,["acoth","arccoth"]
                                    ,["nchoosek","binomial"]
                                    ,["log","ln"]];

matlab_variable_replacement_list := [["pi","Pi"]
                                    ,["i","I"]];                               
                                    
maple_common_function_names := ["arcsinh","arccosh","arctanh","arccsch","arccoth","arcsech"
                               ,"arcsin" ,"arccos" ,"arctan" ,"arccsc" ,"arccot" ,"arcsec"
                               ,"sinh","cosh","tanh","csch","coth","sech"
                               ,"sin" ,"cos" ,"tan" ,"csc" ,"cot" ,"sec"
                               ,"exp"
                               ,"sqrt"
                               ,"log","ln"];
                               

                               
CheckForMapleNotation := proc(inputString) local item,parsedExpression,EqualLoc;

    if StringTools:-Search("!",inputString)>0 then
        error "Unknown Matlab operator !";
    end if;        

    EqualLoc:=StringTools:-Search("=",inputString);
    if EqualLoc > 0 then
      if inputString[EqualLoc..(EqualLoc+1)] <> "==" then
        error "Unexpected assignment operator, use == for equations.";
      end if;
    end if;

    for item in matlab_function_replacement_list do
        if StringTools:-Search(item[2],inputString) > 0 then
            error "Unknown Matlab function: %1",item[2]
        end if;
    end do;
    
    parsedExpression := Matlab:-FromMatlab(inputString,string=true);
    
    for item in matlab_variable_replacement_list do
        if StringTools:-Search(cat("m_",item[2]),parsedExpression) > 0 then
            error "Unknown Matlab variable: %1",item[2]
        end if;
    end do;
    
    
end proc;

                               
decode_common_function_names := proc(inputExpression) local expression;
    expression := inputExpression;

    #for item in maple_common_function_names do
    #    expression := 
    #         subs(
    #             parse(cat(item,"_MAPLE_FUNCTION")) = parse(item)
    #            ,expression
    #         ):
    #end do:

    convert(expression,string);
    StringTools:-SubstituteAll(%,"_MAPLE_FUNCTION","");
    expression := parse(%);

    return expression
end proc;            
                                    
# Modify the matlab string to replace matlab functions
# with standard Maple funcitons.
#   
MatlabStringModify := proc(inputString) local modifiedString,tempString;
    modifiedString:=StringTools:-Trim(inputString):

    # Replace Maple specific names with explicitly labelled functions
    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[2],cat("MAPLE_",item[2])):
    end do:

    # Replace Matlab names function with Maple names
    for item in matlab_function_replacement_list do
        modifiedString := 
             StringTools:-SubstituteAll(modifiedString,item[1],item[2]):
    end do:

    # Protect Maple function names from breaking over elementwise operations inside a matrix
    for item in maple_common_function_names do
        modifiedString := StringTools:-RegSubs(
                cat(item, "([[:space:]]*)\\(")=cat(item, "_MATLAB\\1("),
                modifiedString);
    end do:

    # Fix issues with the repeated operators like '+-' and '++' being careful to preserve space
    tempString := "";
    while tempString <> modifiedString do:
        tempString := modifiedString;
        
        modifiedString := StringTools:-RegSubs("\\+([[:space:]]*)\\+"="+\\1",modifiedString):
        modifiedString := StringTools:-RegSubs("\\+([[:space:]]*)-"  ="-\\1",modifiedString):
        modifiedString := StringTools:-RegSubs("-([[:space:]]*)\\+"  ="-\\1",modifiedString):
        modifiedString := StringTools:-RegSubs("-([[:space:]]*)-"    ="+\\1",modifiedString):
    end do;

    # Fix issues with missing brackets around denominators
    modifiedString := StringTools:-SubstituteAll(modifiedString,"/-","/(-1)/"):
    modifiedString := StringTools:-SubstituteAll(modifiedString,"*-","*(-1)*"):
    
    # Fix issues with the complex number '1/2i' (which is 1/2/i in matlab)
    modifiedString := StringTools:-RegSubs("/[[:space:]]*([0-9]+)[ij]([^A-Za-z]|$)"="/\\1/i\\2",modifiedString);
    
    # Fix issues with the complex number 'i'
    modifiedString := StringTools:-RegSubs("(^|[^A-Za-z])([0-9]+)[ij]([^A-Za-z]|$)"="\\1\\2*i\\3",modifiedString);
    
    return modifiedString;
end proc;

FormatMatlabSyntaxError := proc(ExpressionString,ErrorString)
   StringTools:-Split(ErrorString,"\n");
   [%[2],StringTools:-Substitute(%[3],"^","&uarr;")];
   StringTools:-Join(%,"<br>");
   StringTools:-SubstituteAll(%," ","&nbsp;");
   cat("<p>Matlab Syntax Error:</p><p style=font-family:consolas,monospace;color:red>",%,"</p><p>Please check your input.</p>");
   
   return %;
end proc;

FormatMatlabException := proc(ExpressionString)
   cat("<p style=font-family:consolas,monospace;color:red>",ExpressionString,"</p><p>",
      StringTools:-FormatMessage(_rest)
      ,"</p>");
   return %;
end proc;

FormatMatlabWarning := proc(ExpressionString)
   cat("<p style=font-family:consolas,monospace;color:blue>",ExpressionString,"</p><p>",
      StringTools:-FormatMessage(_rest)
      ,"</p>");
   return %;
end proc;

SuggestCorrectMatlabExpression := proc(ExpressionString) local Message,modifiedString,item,legacyParse;
   Message:=cat("<p style=font-family:consolas,monospace;>",ExpressionString,"</p>");
   
   StringTools:-FormatMessage(_rest);
   cat("<p style=color:red>",%,"</p>");
   Message:=cat(Message,%);
   
   modifiedString:=ExpressionString;
   for item in matlab_function_replacement_list do
        modifiedString:=StringTools:-SubstituteAll(modifiedString,item[2],item[1])
   end do:
   
   modifiedString := StringTools:-RegSubs("([A-Za-z0-9]+)!"="factorial(\\1)",modifiedString);
   modifiedString := StringTools:-RegSubs("\\(([^()]+)\\)!"="factorial(\\1)",modifiedString);
   
   if StringTools:-Search("!",modifiedString)>0 then
       cat("<p>Remember to use <span style=font-family:consolas,monospace;>factorial</span> instead of <span style=font-family:consolas,monospace;>!</span>.</p>");
       Message:=cat(Message,%);
   end if;
   
   for item in matlab_variable_replacement_list do
        modifiedString:=StringTools:-SubstituteAll(modifiedString,cat("m_",item[2]),item[1])
   end do:
      
   if modifiedString <> ExpressionString then
       cat("<p>Did you mean:</p>","<p style=font-family:consolas,monospace;>",modifiedString,"</p>");
       Message:=cat(Message,%);
   end if;
    
   if StringTools:-FormatTime("%Y") <= "2022" then
       try:
           #with(CustomMatlabCompatibility):
       
           legacyParse:=MatlabExpressionParse(ExpressionString):
           #MathML:-ExportPresentation(%); 
           #Message:=cat(Message,"<p>Your expression has been understood as:</p><p align=\"center\">",%,"</p>");
           
           Message:=cat(Message,"<p>Your expression might still be accepted as a correct response, but it would be safer to use standard MATLAB syntax.</p>");
       catch:
       end try:
    end if:
         
   return Message;
end proc;


# Parse a string containing a Matlab expression into a Maple object
#   Maple functions will be transated into 'MAPLE_<function_name>' to
#   allow for optional reparsing.
MatlabExpressionParse := proc(inputString) local modifiedString;
    
    with(CustomMatlabCompatibility);
    
    modifiedString := MatlabStringModify(inputString);

    MatlabString := Matlab:-FromMatlab(modifiedString, string = true); 
    modifiedString := StringTools:-SubstituteAll(%, "evalhf", "");
    modifiedString := StringTools:-SubstituteAll(%, "evalf", "");
    modifiedString := StringTools:-SubstituteAll(%, "Matlab_i", "I");
    
    expression := parse(modifiedString);
    expression := %;

    expression := decode_common_function_names(expression);
    expression := eval(%,i=I);

    convert(%,string):
    modifiedString := StringTools:-SubstituteAll(%, "m_", "");

    if StringTools:-FormatTime("%Y") <= "2022" then
        modifiedString := StringTools:-SubstituteAll(%, "MAPLE_", "");
    end if;

    expression := parse(%);
    expression := %;
    
    return expression;
    
end proc;

CustomPreviewMatlab := proc(inputString) local expression,modifiedString,MatlabString;

    MessageTail:=displayMatlabVersionNumber(""):

    if inputString = "" then
        return ""
    end if;

    with(CustomMatlabCompatibility);
    
    try
    CheckForMapleNotation(inputString);
    
    expression := MatlabStringModify(inputString):
    MatlabString := Matlab:-FromMatlab(expression, string = true); 
    modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", ""); 
    modifiedString := StringTools:-SubstituteAll(%, "evalf", "");
    modifiedString := StringTools:-SubstituteAll(%, "Matlab_i", "I");
    modifiedString := StringTools:-SubstituteAll(%, "m_factorial", "factorial");
    modifiedString := StringTools:-SubstituteAll(%, "m_binomial", "binomial");
    modifiedString := StringTools:-SubstituteAll(%, "m_", "");
    
    expression := parse(modifiedString);
    
    if type(%,Matrix) or type(%,Vector) then
       if max(ArrayTools:-Size(%))>15 then 
          error "previewer warning: Array of size %1 too large to preview.",convert(ArrayTools:-Size(%),list);
       end if;
    end if;
    
    #expression := %;
    # 
    #expression := decode_common_function_names(expression);
    MathML:-ExportPresentation(%); 
    
    Message:=cat("<p align=\"center\">",%,"</p>");
        
    return cat(Message,MessageTail);
 
    catch "numeric exception","Unexpected assignment operator":
        Message := FormatMatlabException(inputString,lastexception[2..]);
    catch "previewer warning":
        Message := FormatMatlabWarning(inputString,lastexception[2..]);
    catch "Unknown Matlab":
        Message := SuggestCorrectMatlabExpression(inputString,lastexception[2..]);
    catch "this entry is too": 
        #'too wide','too tall','too wide or too narrow'
        Message := FormatMatlabException(inputString,"Dimensions of arrays being concatenated are not consistent.")
    catch "dimension bounds must be the same":
        Message := FormatMatlabException(inputString,"Matrix dimensions must agree.")
    catch "Arrays have incompatible sizes for this operation.":
        Message := FormatMatlabException(inputString,"Arrays have incompatible sizes for this operation.")
    catch:
        if StringTools:-Search("syntax error",lastexception[2]) > 0 then
            Message := FormatMatlabSyntaxError(inputString,lastexception[2])
        else
            Message:= cat("<p style=font-family:consolas,monospace align=center>",inputString,"</p><p>Unanticipated error occured, please take a screenshot and send this to your course M&ouml;bius contact.<br>If the exception message below does not help you, it means you cannot rely on the preview to tell you if your syntax is correct. Please double-check it.</p>");
            Message:= cat(Message,"<p style=color:blue> Last reported exception: ", StringTools:-FormatMessage(lastexception[2..]),"</p>");       
        end if;
    end try;    
    
    return cat(Message,MessageTail);
end proc;


# The older code for parse a string containing a Matlab expression into a Maple object
#   This code will be use to attempt parsing the code when the updated version fails.
LegacyMatlabExpressionParse := proc(inputString) local modifiedString;
    
    modifiedString := MatlabStringModify(inputString);
    
    if evalf(StringTools:-Search("[",inputString)>0) then
        MatlabString := Matlab:-FromMatlab(modifiedString, string = true); 
        modifiedString := StringTools:-SubstituteAll(MatlabString, "evalhf", "");
        
        expression := parse(modifiedString);
        expression := %;
    else
        expression := MatlabStringModify(inputString):
        if evalb(StringTools:-Search("binomial",expression)>0) then
            expression := StringTools:-SubstituteAll(expression,"binomial","C")
        end if;
        expression := InertForm:-Parse(expression);
        expression := InertForm:-Value(expression);
    end if;   
    
    expression := decode_common_function_names(expression);
    expression := eval(%,i=I);
    
    return expression;
    
end proc;


StringTools:-RegSubs("[ .]" = "_", MatlabPreviewerVersion());
StringTools:-RegSubs("[^A-Za-z0-9_-]" = "",%);
previewerVersion:=%;

libraryname := cat("PreviewMatlabExpression_"
                  ,previewerVersion
                  ,".lib");

for this_libname in [libraryname,"PreviewMatlabExpression.lib"] do
  march('create',this_libname):
  savelib('MatlabStringModify'
       ,'CustomMatlabCompatibility'
       ,'CheckForMapleNotation'
       ,'SuggestCorrectMatlabExpression'
       ,'MatlabExpressionParse'
       ,'FormatMatlabSyntaxError'
       ,'FormatMatlabException'
       ,'FormatMatlabWarning'
       ,'CustomPreviewMatlab'
       ,'matlab_function_replacement_list'
       ,'matlab_variable_replacement_list'
       ,'maple_common_function_names'
       ,'decode_common_function_names'
       ,'MatlabPreviewerVersion'
       ,'displayMatlabVersionNumber'
       ,'LegacyMatlabExpressionParse'
       ,this_libname);
end do;

#To use add the following to the Custom Preview:
#     Message := CustomPreviewMatlab("$RESPONSE"); printf("%s",Message);
#

