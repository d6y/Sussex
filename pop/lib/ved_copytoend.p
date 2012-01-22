;;; VED_COPYTOEND
;;; Aaron Sloman
;;; From PLUG No.6, Summber 1990
;;; page 8

define ved_copytoend;
;;; <ENTER> copytoend - copy current line to
;;; end of file and go there, preserving current
;;; cursor column.
lvars
    line = veddecodetabs(vedthisline()),
    col = vedcolumn;
dlocal vedbreak = false;    ;;; in case a long line

vedendfile();
vedinsertstring(line);
col -> vedcolumn;
enddefine;
