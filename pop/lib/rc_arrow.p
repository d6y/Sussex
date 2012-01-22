/*

    RC_ARROW.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    From code and help by: Paulo Savio Da Silva Costa <pauloc@cogs.susx.ac.uk>

    For use with RC_GRAPHIC.

    rc_add_arrow(x0,y0,x1,y1,position,text)

        Adds an arrow head to the line (x0,y0) (x1,y1).  The variable
        "position" determines which end of the line (1.0 for the far
        end of x1,y1, and 0.0 for x0,y0 --- 0.5 means "the middle of the
        line").

        If "text" is not <false> and a string, the string is printed next to
        the arrow head. The procedure tries to place the string on an
        appropriate side of the line.


    rc_arrow_line(x0,y0,x1,y1,position)
    rc_arrow_line(x0,y0,x1,y1,position,text)

    rc_no_arrow(x0,y0,x1,y1,position,text)

        Draws the line, annotates with text, but does not draw the
        arrow head.


*/

;;;uses rcg;


vars rc_arrow_length = 10;
vars rc_arrow_angle = 1;    ;;; One radian; smaller for a wider angle


define rc_add_arrow(x0,y0,x1,y1,position,text);
    vars popradians = true;
    lvars theta, theta_plus, theta_minus, x2,y2,x3,y3;

    arctan2(y0-y1,x0-x1) -> theta;
    theta + rc_arrow_angle -> theta_plus;
    theta - rc_arrow_angle -> theta_minus;

    x0 + (x1-x0)*position -> x1;
    y0 + (y1-y0)*position -> y1;

    (x1 - rc_arrow_length * cos(theta_plus)) -> x2;
    (y1 + rc_arrow_length * sin(theta_plus)) -> y2;
    (x1 + rc_arrow_length * cos(theta_minus)) -> x3;
    (y1 - rc_arrow_length * sin(theta_minus)) -> y3;

    rc_jumpto(x2,y2); rc_drawto(x1,y1); rc_drawto(x3,y3);

    ;;; Position text the correct side of the line
    unless text==false then
        if (theta > 0 and theta < pi/2) or
            (theta > -pi and theta < -pi/2)  then
            rc_print_at(x1+rc_arrow_length,y1,''><text);
        else
            rc_print_at(x1-(rc_arrow_length+XpwTextWidth(rc_window,''><text)),y1,''><text);
        endif;
    endunless;

enddefine;

define rc_arrow_line(x0,y0,x1,y1,position);
vars text = false;

    if isstring(position) or isword(position)  then
        (x0,y0,x1,y1,position) -> (x0,y0,x1,y1,position,text);
    endif;

    rc_jumpto(x0,y0); rc_drawto(x1,y1);
    rc_add_arrow(x0,y0,x1,y1,position,text);
enddefine;


define rc_no_arrow;
    vars rc_arrow_length = 0.0;
    rc_arrow_line();
enddefine;

vars rc_arrow=true;
