(* This Maple input file will test what features and bugs exist
   and report back any changes *)
###############################################################

(* The expression "1/-2" should okay if parseed as Matlab, but
   the FromMatlab command is know to identify this as an error *)

broken := true:
try:
   Matlab:-FromMatlab("1/-2");
   broken := false;

catch "incorrect syntax in parse":
   broken := true;
catch:
   error "Unexpected error in failing to parse 1/-2";
end try:

if broken = false then
   error "Unexpected error in failing to parse 1/-2";
end if;

#TODO: APPEND RESULT TO LOG FILE

 
