/*
    RCG_HINTON.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Tuesday 10 December 1991

    Draws a hinton diagram

    Usage: rcg_hinton_line(list_of_values,list_of_lables,scale);
           (list_of_lables may be <false>)


           rcg_hinton(xyvalues, xlables, ylables, scale);

*/

uses rcg;

define plt_hinton(x,y,v);
    abs(v) -> rcg_pt_cs;
    sign(v) -> v;
    ;;; possibly a politically-incorrect euro-imperialist hang-up
    if v = 1 then          ;;; white is +ve
        rcg_plt_square(x,y);
    elseif v = -1 then     ;;; black is -ve
        rcg_plt_box(x,y);
    else ;;; don't plot zero
    endif;
enddefine;

define rcg_hinton_line(values, lables, box_scale);
    vars last_value, p, points, largest;

    if isarray(values) then
        arraytovector(values) -> values;
    endif;

    length(values) -> last_value;

    0 -> largest;
    [% fast_for p from 1 to last_value do
        p; 1;
       if abs(values(p)) > largest then abs(values(p)) -> largest; endif;
    endfast_for; %] -> points;

    procedure(x,y);
        plt_hinton(x,y,values(x)*box_scale);
        unless lables = false then
            rc_print_at(x,y-largest/rc_yscale,''><lables(x));
        endunless;
   endprocedure -> rcg_pt_type;

    rc_graphplot2(points,false,false) -> region;
enddefine;


define rcg_hinton(xylist,xlables,ylables,box_scale);
    lvars x,y, xlength, item, largest_xlength = 0;

    vars rcg_win_reg = 0.05, rcg_usr_reg;

    [% fast_for y from 1 to length(xylist) do
            xylist(y) -> item;
            if isarray(item) then arraytovector(item) -> item; endif;
            length(item) -> xlength;
            if xlength > largest_xlength then
                xlength -> largest_xlength;
            endif;
            fast_for x from 1 to xlength do
                x; y;
            endfast_for;
        endfast_for; %] -> points;

    procedure(x,y);
        lvars v = 0;
        unless length(xylist(y)) < x then
            xylist(y)(x) -> v;
        endunless;
        plt_hinton(x,y,v*box_scale);
    endprocedure -> rcg_pt_type;

    [0 ^(largest_xlength+1) 0 ^(length(xylist)+1)] -> rcg_usr_reg;
    rc_graphplot2(points,false,false) -> region;

    unless xlables = false then
        for x from 1 to length(xlables) do
            rc_print_at(x-0.35,0,''><xlables(x));
        endfor;
    endunless;

    unless ylables = false then
        for y from 1 to length(ylables) do
            rc_print_at(-0.5,y,''><ylables(y));
        endfor;
    endunless;

enddefine;
