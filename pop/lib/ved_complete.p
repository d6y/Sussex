/*
 * File:             ~richard/pop/lib/ved_complete.p
 * Author:           Richard Dallaway
 * Machine:          tsuna (unix bsd 4.2)
 * Date:             April 8th, 1989
 * Last Update:      April 13rd, 1989
 * Run with:         <ENTER> COMPLETE or <ESC> b
 * Purpose:

    In .tex file:   Current line which is \begin{<env>} is
                    used to produce a \end{<env>} line.

    In .p files:    A 'define' command on the current line is
                    used to produce an 'enddefine' statement.
                    same for while, until, for, fast_for, if,
                    foreach, forevery.

   HISTORY: April 13rd, 1989: Now keeps indentation.

 */

define ved_complete;

    vars e_string,c,start,endbit,nomatch = true;

    vars structures = [
             [define enddefine]
             [until enduntil]
             [while endwhile]
             [for endfor]
             [fast_for endfast_for]
             [foreach endforeach]
             [forevery endforevery]
             [repeat endrepeat]
             [procedure endprocedure]
             [unless endunless]
             [if endif]
             [switchon endswitchon]
             [defmethod enddefmethod]
             [flavour endflavour]
             ];

    ;;; Mostly stolen from ved_heading

    vars char,spaces = '',f_string = vedthisline();
    1 -> vedcolumn;
    ;;; get rid of leading hyphens or spaces
    while (vedcurrentchar()->>char) == `\t` or char == ` ` do
        vedcharright(); vedchardelete();
        if char == `\t` then
            spaces >< '\t' -> spaces;
        else
            spaces >< ' ' -> spaces;
        endif;
    endwhile;

    spaces >< f_string -> f_string;

    ;;; get rid of trailing hyphens
    vvedlinesize -> vedcolumn;
    while (vedcurrentchar()->>char) == `-` or char== ` ` do
        vedcharleft();
    endwhile;
    vedcharright(); vedcleartail();
    1 -> vedcolumn;

    vedthisline() -> e_string;

    ;;;remove trailing spaces
    while e_string(length(e_string)) == 32 do
        substring(1,length(e_string)-1,e_string) -> e_string;
    endwhile;

    vedtextright();
    vednextline();

    if substring(length(vedpathname)-1,2,vedpathname) = '.p' then ;;; pop11
        foreach [?start ?endbit] in structures do
            ;;;convert to string;;; not( and ensure is a seperate word)
            start >< '' -> start;
            if length(e_string) > (length(start)-1) then
                if substring(1,length(start),e_string) = start then
                    false -> nomatch;
                    vedinsertstring('\n'><spaces><endbit><';\n');
                    vedcharup();
                    vedcharup();
                    vedscreenleft();
                    vedcharup();
                    f_string -> vedthisline();    ;;; restore orig. line
                    vedchardown();
                    vedalignscreen(); ;;; refresh
                endif;
            endif;
        endforeach;

/*        if nomatch then
            ;;; define is a special case
            if length(e_string) > 5 then
                if substring(1,6,e_string) = 'define' then
                    ;;;remove 'define'
                    substring(8,length(e_string)-7,e_string) -> e_string;
                    ;;;strip off parameters
                    1 -> c;
                    while substring(c,1,e_string) /= '(' and
                        substring(c,1,e_string) /= ';' do
                        c + 1 -> c;
                    endwhile;
                    substring(1,c-1,e_string) -> e_string;
                    ;;;insert enddefine line
                    vedinsertstring('\nenddefine; /* '><e_string >< ' */');
                    vedcharup();
                    vedscreenleft();
                endif;
            endif;
        endif;
*/
    elseif substring(length(vedpathname)-3,4,vedpathname) = '.tex' then ;;; TeX
        if length(e_string) > 6 then
            if substring(1,7,e_string) = '\\begin{' then
                substring(8,length(e_string)-8,e_string) -> e_string;
                vedinsertstring('\n\\end{'><e_string><'}');
                vedscreenleft();
                vedcharup();
            else
                vedputmessage('Couldn\'t find \\begin');
            endif;
        else
            vedputmessage('Couldn\'t find \\begin');
        endif;

    else
        vedputmessage('Not in TeX or POP-11 file');
    endif;

enddefine;
