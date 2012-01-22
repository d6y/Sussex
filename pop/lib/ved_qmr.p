
define ved_uqmr;
    dlocal vedstatic=false;
	vars c;
	if vedargument /= '' then vedargument;
	else '@?';
	endif; -> c;
    if vvedmarklo > vvedmarkhi then
        vederror('NO MARKED RANGE');
    else
        veddo('gsr/@a'><c><' ///');
    endif;
enddefine;

define ved_qmr;
    dlocal vedstatic=false;
	vars c;
	if vedargument /= '' then vedargument;
	else '>';
	endif; -> c;
    if vvedmarklo > vvedmarkhi then
        vederror('NO MARKED RANGE');
    else
        veddo('gsr/@a/'><c><' /');
    endif;

enddefine;
