vars full_date;

define ved_today();
vars year day month day_name ending full;

    ;;; unix only

    substring(1,3,sysdaytime()) -> day_name;
    substring(5,3,sysdaytime()) -> month;
    substring(25,4,sysdaytime()) -> year;
    substring(9,2,sysdaytime()) -> day;

    substring(2,1,day) -> full;

    if day = '11' then 'th' -> full;
    elseif day = '12' then 'nd' -> full;
    elseif day = '13' then 'rd' -> full;
    else
        if full = '1' then 'st' -> full;
        elseif full = '2' then 'nd' -> full;
        elseif full = '3' then 'rd' -> full;
        else 'th' -> full;
        endif;
    endif;
    full -> ending;

    if subscrs(1,day) = 32 then substring(10,1,sysdaytime()) -> day;
    endif;

    ['Sat' 'Saturday' 'Sun' 'Sunday' 'Mon' 'Monday'
        'Tue' 'Tuesday' 'Wed' 'Wednesday' 'Thu' 'Thursday'
        'Fri' 'Friday'] --> [== ^day_name ?full ==];
    full -> day_name;


    ['Jan' 'January' 'Feb' 'February' 'Mar' 'March'
        'Apr' 'April' 'May' 'May' 'Jun' 'June' 'Jul' 'July' 'Aug' 'August'
        'Sep' 'September' 'Oct' 'October' 'Nov' 'November' 'Dec' 'December']
        --> [== ^month ?full ==];
    full -> month;

day_name >< ' ' ><  day  ><
    ' ' >< month >< ' ' >< year -> full_date;

vedinsertstring(full_date);
enddefine;
