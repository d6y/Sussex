uses rcg;
vars rc_bc_bar_gap = 1.2;
vars rc_bc_shrink = 4;
vars rc_bc_barwidth = 1;

define rc_bc_vector(bars,x) -> (data,x);
    {% for number in bars using_subscriptor subscrv do
            if isvector(number) then
                x + rc_bc_bar_gap/rc_bc_shrink -> x;
                x + rc_bc_bar_gap -> x;
                rc_bc_vector(number,x) -> (data,x);
                explode(data);
                x + rc_bc_bar_gap/rc_bc_shrink -> x;
            else
                x; 0; x; number; x+rc_bc_barwidth; number;
                x+rc_bc_barwidth; 0; undef; undef;
            endif;
            x + rc_bc_bar_gap -> x;
        endfor; %} -> data;
enddefine;

define rcg_barchart(bars);
    vars l,x,data;
    rc_bc_vector(bars,1) -> (data,x);
    rc_graphplot2(data, false, '') -> region;
    region --> [= ?l = =];
    rc_drawline(0,0,l,0);
enddefine;
