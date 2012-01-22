
/* Procedures for <ENTER> ma and <ENTER> ta
 * (Move About and Transfer About).
 * Author:  Mr Bob */

define max_width();
    vars filetype,width;
        sysfiletype(vedcurrent) -> filetype;
            if filetype = 'p' or filetype = 'com' then 176 -> width
            else 80 -> width;
            endif;
    ;;;return(width);
    return(vedlinemax);
enddefine;

define check_space();
    vars line;
        for line from vvedmarklo to vvedmarkhi do
            if length(vedbuffer(line)) > (max_width() - vedcolumn)
                then return(false)
            endif
        endfor;
    return(true);
enddefine;

define stickin();
    vars counter size line column;
        length(vveddump) -> size;
        vedcolumn -> column;
            for counter from 1 to size do
                vedinsertstring(vveddump(counter));
                column -> vedcolumn;
                vedtrimline();
                vedline +1 -> vedline;
            endfor;
enddefine;

define ved_ma();
    vars counter size;
        if vedmarkhi = 0
            then vedputmessage('No Marked Range')
        elseif check_space() = false
            then vedputmessage('Not Enough Space')
        else ved_d();
             stickin();
        endif;
enddefine;
