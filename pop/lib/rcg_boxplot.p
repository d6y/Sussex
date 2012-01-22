/*  RCG_BOXPLOT.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Tuesday 17th September 1991

    Given a list of x,y values, draws a BOXPLOT using
    rc_graphplot routines.

    Input is a list of y-values and a text string.
    If the text string is <false>, no statistical text
    is printed above the boxplot.

    Example from Howell "Statistical Methods for Psychology" (p.48,
        second edition).

    vars v = [2 1 2 3 3 9 4 20 4 1 3 2 3 2 1 33 3 3 2 3 6 5 3 3 2 4 7 2 4 4
        10 5 3 2 2 4 4 3];

    rcg_boxplot(v,'Hospitalization length');


*/

uses rcg;
uses statlib;

define rcg_boxplot(yvals,text);
    vars y, ylength = length(yvals) ;

    ;;; Step 0. Sort data.
    sort(yvals) -> yvals;

    vars x1 = yvals(1);

    ;;; Step 1.  Find Hinge locations
    /*
    vars hinge_location = intof(((intof((ylength+1)/2) + 1)/2));
    vars upper_hinge = yvals(ylength - hinge_location);
    vars lower_hinge = yvals(hinge_location);
    */

    vars hinge_location = (intof((ylength+1)/2) + 1)/2;
    vars upper_hinge, lower_hinge;

    if hinge_location /= intof(hinge_location) then
        intof(hinge_location) -> hinge_location;
        ( yvals(ylength-hinge_location) +
            yvals(ylength-hinge_location+1) ) / 2
            -> upper_hinge;
        ( yvals(hinge_location) + yvals(hinge_location+1) ) / 2
            -> lower_hinge;
    else
        yvals(ylength - hinge_location) -> upper_hinge;
        yvals(hinge_location) -> lower_hinge;
    endif;


    ;;; Step 2. Find the H-spread
    vars H_spread = upper_hinge - lower_hinge;

    ;;; Step 4. Find the inner fence

    vars inner_fence = 1.5 * H_spread;
    vars lower_fence = lower_hinge - inner_fence;
    vars upper_fence = upper_hinge + inner_fence;

    ;;; Step 5. Adjacent values

    vars lower_adj, upper_adj, position;

    1 -> position;
    repeat
        if yvals(position) >= lower_fence then
            yvals(position) -> lower_adj;
            quitloop;
        else
            position + 1 -> position;
        endif;
    endrepeat;


    ylength -> position;
    repeat
        if yvals(position) =< upper_fence then
            yvals(position) -> upper_adj;
            quitloop;
        else
            position - 1 -> position;
        endif;
    endrepeat;

    ;;; Step 6. Draw boxplot.

    vars median_value = median(yvals);
    rc_start();

    vars shave = 10/rc_xscale;

    if text = false then
        rcg_set_reg([^(x1-shave) ^(yvals(ylength)+shave) 1 4]) -> region;
    else
        rcg_set_reg([^(x1-shave) ^(yvals(ylength)+shave) 1 8]) -> region;
    endif;

    ;;; Axis
    rcg_def_ax(x1,yvals(ylength),'',1,10,false);

    ;;; Draw hinge box and median

    rc_jumpto(lower_hinge,4);
    rc_draw_rectangle(H_spread,2);

    rc_jumpto(median_value,4);
    rc_drawto(median_value,2);

    ;;; Draw whiskers

    LineOnOffDash -> rc_linestyle;

    vars whisker_line = 3;
    rc_jumpto(lower_adj,whisker_line);
    rc_drawto(lower_hinge,whisker_line);

    rc_jumpto(upper_adj,whisker_line);
    rc_drawto(upper_hinge,whisker_line);

    LineSolid -> rc_linestyle;

    ;;; Draw outliers

    vars count = 0;
    fast_for position from 1 to ylength do
        yvals(position ) -> y;
        if y > upper_adj or y < lower_adj then
            rcg_plt_cross(y,whisker_line);
            count + 1 -> count;
        endif;
    endfast_for;

    ;;; Information
    unless text = false then

        vars x2 = x1+(yvals(ylength)-yvals(1))/2, y = 5.5;
        rc_print_at(x1,y+2.5,'BOXPLOT: '><text);

        rc_print_at(x1,y+1.5,  'Median = '><median_value);
        rc_print_at(x1,y+1,'Mean = '><mean(yvals));
        vars mo = mode(yvals);
        if length(mo)>3 then
            rc_print_at(x1,y+0.5,'Mode = '><mo(1)><' +'><length(mo)><'...');
        else
            rc_print_at(x1,y+0.5,'Mode = '><mo);
        endif;
        rc_print_at(x1,y,  'Std dev = '><SD(yvals));

        rc_print_at(x2,y+1.5,'Lower adj = '><lower_adj);
        rc_print_at(x2,y+1,'Upper adj = '><upper_adj);
        rc_print_at(x2,y+0.5,'H-spread = '><(1.0*H_spread));
        rc_print_at(x2,y,'No. outliers = '><count);
    endunless;
enddefine;
