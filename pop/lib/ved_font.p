uses stringtolist;

vars ved_font_list = [

    [bold [
            ['-adobe-courier-bold-r-normal--0-0-100-100-m-0-iso8859-1']
            ['-adobe-courier-bold-r-normal--8-80-75-75-m-50-iso8859-1']
            ['-adobe-courier-bold-r-normal--10-100-75-75-m-60-iso8859-1']
            ['-adobe-courier-bold-r-normal--11-80-100-100-m-60-iso8859-1']
            ['-adobe-courier-bold-r-normal--12-120-75-75-m-70-iso8859-1']
            ['-adobe-courier-bold-r-normal--14-100-100-100-m-90-iso8859-1']
            ['-adobe-courier-bold-r-normal--17-120-100-100-m-100-iso8859-1']
            ['-adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-1']
            ['-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1']
            ['-adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-1']
            ['-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1']
            ['-adobe-courier-bold-r-normal--34-240-100-100-m-200-iso8859-1']
        ]
    ]


    [medium [
            ['-adobe-courier-medium-r-normal--0-0-100-100-m-0-iso8859-1']
            ['-adobe-courier-medium-r-normal--8-80-75-75-m-50-iso8859-1']
            ['-adobe-courier-medium-r-normal--10-100-75-75-m-60-iso8859-1']
            ['-adobe-courier-medium-r-normal--11-80-100-100-m-60-iso8859-1']
            ['-adobe-courier-medium-r-normal--12-120-75-75-m-70-iso8859-1']
            ['-adobe-courier-medium-r-normal--14-100-100-100-m-90-iso8859-1']
            ['-adobe-courier-medium-r-normal--17-120-100-100-m-100-iso8859-1']
            ['-adobe-courier-medium-r-normal--18-180-75-75-m-110-iso8859-1']
            ['-adobe-courier-medium-r-normal--20-140-100-100-m-110-iso8859-1']
            ['-adobe-courier-medium-r-normal--24-240-75-75-m-150-iso8859-1']
            ['-adobe-courier-medium-r-normal--34-240-100-100-m-200-iso8859-1']
        ]
    ]
];



vars
    ved_font_bold = true,
    ved_font_number = 8; ;;; In my .xrdb


define ved_font_check(n,type) -> font;
    vars font_names;
    ved_font_list --> [== [^type ?font_names]==];
    if length(font_names) < n or n<1 then
        false -> font;  ;;; Not that this matters really
        vederror('There are '><(length(font_names))><' '><type><' fonts');
    endif;
    font_names(n)(1) -> font;
enddefine;


define ved_font;
    vars args, n, font, pre_text = '';

    if vedargument = '' then
        vedputmessage('Font number '><ved_font_number);
        return;
    endif;


    stringtolist(vedargument) -> args;

    if member("default",args) then
        ' default ' -> pre_text;
        delete("default",args) -> args;
        if args = [] then [^ved_font_number] -> args; endif;
    endif;

    args(1) -> n;

    if length(args) > 1 then
        if args(2)(1) = `b` then ;;; bold
            true -> ved_font_bold;
        else
            false -> ved_font_bold;
        endif;
    endif;

    if length(args) = 1 and not(isnumber(args(1))) then
        if args(1)(1) = `b` then ;;; bold
            true -> ved_font_bold;
        else
            false -> ved_font_bold;
        endif;
        ved_font_number -> n;
    endif;

    if ved_font_bold then
        ved_font_check(n,"bold") -> font;
    else
        ved_font_check(n,"medium") -> font;
    endif;

    unless font = false then
        veddo('window '><pre_text><' font '><font);
        n -> ved_font_number;
    endunless;

enddefine;

;;; ESC = (plus) for larger font, esc - for smaller
vedsetkey('\^[=', procedure; veddo('font '><(ved_font_number+1)); endprocedure);
vedsetkey('\^[-', procedure; veddo('font '><(ved_font_number-1)); endprocedure);
;;; ESC + (shifted plus button) and SHIFT - to change size of default window
vedsetkey('\^[+', procedure; veddo('font '><(ved_font_number+1));
    veddo('font default'); endprocedure);
vedsetkey('\^[_', procedure; veddo('font '><(ved_font_number-1));
    veddo('font default'); endprocedure);
