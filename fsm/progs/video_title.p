

define title_screen(list);
    rc_start();
    vars line, y=2.0;

    XpwSetFont(rc_window,
        '-adobe-helvetica-medium-r-normal--*-240-*-*-p-*-iso8859-1')->;

    for line in list do
        rc_print_at(-2.5,y,line);
        y-0.5 -> y;
    endfor;
enddefine;

define countdown(n);
lvars n,i,now;
    for i from n by -1 to 1 do
        rc_print_at(0,0,''><i);
        systime() -> now;
        while systime()-now < 100 do ; endwhile;
        rc_start();
    endfor;
enddefine;

define normal_font;

XpwSetFont(rc_window,
    '-adobe-helvetica-medium-r-normal--*-120-*-*-p-*-iso8859-1')->;

enddefine;
