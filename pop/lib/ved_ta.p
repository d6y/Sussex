uses ved_ma;

define ved_ta();
    vars counter size;
        if vedmarkhi = 0
            then vedputmessage('No Marked Range')
        elseif check_space() = false
            then vedputmessage('Not Enough Space')
        else ved_copy();
             stickin();
        endif;
enddefine;
