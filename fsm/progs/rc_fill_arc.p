
define rc_fill_arc(/*x, y*/, width, height, angle1, angleinc);
    lvars x, y, width, height, angle1, angleinc;
    ;;; See the man XDrawArc file
    ;;; Draws an arc on a circle or ellipse bounded by the rectangle whose top
    ;;; left corner is (x, y), with given width and height, all in user
    ;;; co-ordinates
    ;;; The arc is defined by the start angle of the radius angle1 and
    ;;; the amount it is to be increased angleinc, measured from the
    ;;; three O'clock position, in 64ths of a degree, counterclockwise
    ;;; (negative angles are measured clockwise).
    rc_getxy() -> y -> x;
    XpwFillArc(rc_window,
        rc_transxyout(x,y),
        round(abs(width * rc_xscale)), round(abs(height * rc_yscale)),
        round(angle1), round(angleinc))
enddefine;
