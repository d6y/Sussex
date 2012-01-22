/*  RCG_TRACEPLOT.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Monday 23 September 1991

    Proceduire for plotting arrays left to right across screen.
    Usage: rcg_traceplot(listofvectors,listofoutputnames,boxscale);

*/

uses rcg;

define rcgtp(layers) -> (points, height);
    vars x,y,lx,column;
    0 -> height;
    [% for x from 1 to length(layers) do
            layers(x) -> column;
            if islist(column) or isvector(column) then
                length(column) -> lx;
            else
                boundslist(column)(2) -> lx;
            endif;
             if lx > height then lx -> height; endif;
            for y from 1 to lx do
                {% x; y; %};
            endfor;
        endfor; %] -> points;
enddefine;

define rcg_traceplot(layers,names,box_scale);
    rc_start();
    vars height,i,points,lng,hgh,rcg_pt_cs, rcg_win_reg=0.05,
        rcg_pt_type = procedure(x,y);
            layers(x)(y)*box_scale -> rcg_pt_cs;
    if layers(x)(y) > 0.1 then rcg_plt_square(x,y); endif;
            endprocedure;
[loading version of rcg_traceplot with a minimum threshold]=>
[for plotting squares (0.1).] =>
    vars rcg_newgraph = false;
    rcgtp(layers) -> (points,height);
    vars rcg_usr_reg = [0 ^(length(layers)+1) 0 ^(height+1)];
    rc_graphplot2(points,false,false) -> region;
    unless names = false then
        fast_for i from 1 to length(names) do
            rc_print_at(-1.0,i-0.25,''><names(i));
        endfast_for;
    endunless;
    box_scale -> rcg_pt_cs;
;;;    rcg_plt_square(length(layers),0.2);
;;;    rc_print_at(length(layers)+0.2,0,'=1');

enddefine;
