uses stripquotes;

;;; Reads x, y data for file to plot
;;; Can have lable as third item on a line

define rcg_gfile(filename);
    vars p,dev = fopen(filename,"r"), lab = [],
        xyvals = [%
            repeat
            fgetstring(dev) -> line;
        if line = termin then quitloop endif;
        stringtolist(stripquotes(line))->line;

        if length(line) = 3 then
            line(3) -> l;
            if l = "zero" then
                '?' :: lab -> lab;
                line(1); line(2);
            else
                strnumber(substring(2,1,l)) -> a;
                strnumber(substring(4,1,l)) -> b;
                if member(a,[2 3]) and member(b,[7 8 9]) and
    not((a=2 and b=7)) and not(a=2 and b=9) then
                    line(1); line(2);
                        (''><a*b) :: lab -> lab;
                endif;
            endif;
else  line(1); line(2);
        endif;
    endrepeat;%];

    unless lab = [] then
        rev(lab) -> lab;
        1 -> p;
        procedure(x,y); rc_print_at(x-0.01,y-0.01,lab(p)); p+1->p;
        endprocedure -> rcg_pt_type;
    else
        "line" -> rcg_pt_type;
    endunless;

    rc_graphplot2(xyvals,'','') -> region;

enddefine;
