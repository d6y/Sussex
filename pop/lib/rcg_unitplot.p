
/*  RCG_UNITPLOT.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Friday 12 April 1991

    Procedures for plotting vectors with rc_graphplot

    Usage: rcg_unitplot(listofvectors,layernames,boxscale);

*/

uses rcg;

define rcup_conv(list) -> points -> lng;
vars x,y,lng=0, points = {%
    for y from 1 to length(list) do
        if length(list(y)) > lng then
            length(list(y))->lng;
        endif;
        for x from 1 to length(list(y)) do
        x; y;
        endfor;
    endfor;
%};
enddefine;


define rcg_unitplot(layers,names,box_scale);
    vars i,points,lng,hgh,rcg_pt_cs, rcg_win_reg=0.05,
        rcg_pt_type = procedure(x,y);
        layers(y)(x)*box_scale -> rcg_pt_cs;
        rcg_plt_square(x,y); endprocedure;
    rcup_conv(layers) -> points -> lng;
    vars rcg_usr_reg = [0 ^(lng+1) 0 ^(length(layers)+1)];
    rc_graphplot2(points,false,false) -> region;
    unless names = false then
    fast_for i from 1 to length(names) do
        rc_print_at(0,i-0.5,''><names(i));
    endfast_for;
    endunless;
enddefine;

define rcg_unitplot_cross(layers,names,box_scale);
    vars i,points,lng,hgh,rcg_pt_cs, rcg_win_reg=0.05,
        rcg_pt_type = procedure(x,y);
    if layers(y)(x) < 0 then
        intof(box_scale/2) -> rcg_pt_cs;
        rcg_plt_cross(x,y);
    else
        layers(y)(x)*box_scale -> rcg_pt_cs;
        rcg_plt_square(x,y);
    endif; endprocedure;
    rcup_conv(layers) -> points -> lng;
    vars rcg_usr_reg = [0 ^(lng+1) 0 ^(length(layers)+1)];
    rc_graphplot2(points,false,false) -> region;
    unless names = false then
    fast_for i from 1 to length(names) do
        rc_print_at(0,i-0.5,''><names(i));
    endfast_for;
    endunless;
enddefine;
