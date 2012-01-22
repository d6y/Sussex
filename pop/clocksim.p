
vars
    wrong_hour = 0, wrong_mins = 0,
    hour = 0, mins = 0,
    wrong_rate = 30/60;


define change_time(m,h) -> (m,h);
    lvars m,h;
    if m >= 60 then
        h + 1 -> h;
        if h > 12 then
            0 -> h;
        endif;
        m-60 -> m;
    endif;

enddefine;


repeat
    if wrong_hour == hour and wrong_mins == mins then
        [Same time at ^hour hours ^mins minutes] =>
    endif;
    change_time(mins + 1, hour) -> (mins, hour);
    change_time(wrong_mins + wrong_rate, wrong_hour)
        -> (wrong_mins,wrong_hour);
endrepeat;
