
vars twoup_args;
unless isstring(twoup_args) then
    '-F7.5 -nH' -> twoup_args;
endunless;


define ved_twoup;
    lvars
        printer = systranslate('$PRINTER'),
        args = twoup_args;

    if vedargument /= '' then
        if vedargument(1) = `d` then
            '' -> twoup_args;
        else
            twoup_args >< ' ' >< vedargument -> twoup_args;
        endif;
    endif;

    if vedwriteable then ved_w1(); endif;
    vedputmessage('Printing two-up on '><printer><'...');
    sysobey('a2ps '><twoup_args><' '><vedpathname><' | lpr -P '><printer,`%`);

    ;;; Restore two_args to it's default
    args -> twoup_args;

    vedputmessage('DONE');


enddefine;
