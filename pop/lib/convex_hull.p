/* --- Copyright University of Sussex 1993. All rights reserved. ----------
 > File:            $poplocal/local/lib/convex_hull.p
 > Purpose:         Finds convex hull polygon lines from a set of points
 > Author:          Richard Dallaway, Mar 12 1993
 > Documentation:   HELP * CONVEX_HULL
 > Related Files:   HELP * RC_GRAPHIC
 */

compile_mode:pop11 +strict;

section convex_hull_section => convex_hull;

vars popradians=true;

constant two_pi = pi*2;
constant two_pi_plus_one = two_pi + 1;

defclass procedure point_record { Px, Py };

define normalize(theta) -> theta;
    lvars theta;
    while theta > two_pi do theta - two_pi -> theta; endwhile;
    while theta < 0 do theta + two_pi -> theta; endwhile;
enddefine;


/*

ASSUMES THAT THE Y AXIS INCREASES DOWN THE SCREEN (I.E., THAT THE
SMALLEST Y POOINT IS AT THE TOP OF THE SCREEN).

points should be a list containing a list [x y] for each point

lines is a flat list containing 4*n points defining an n-sided
polygon (almost suitable for presenting to * XpwMFillPolygon).  Each
four points represents a line (x0,y0) to (x1,y1).

If the user is really going to pass "lines" to XpwMFillPolygon
then the points list should have been converted with -rc_transxyout-,
and the lines list have to be rev()ed and flatten()ed (see example in
HELP * CONVEX_HULL)

*/

define global convex_hull(points) -> lines;

    lvars
        points, lines, xy,
        npoints = length(points),
        point_array = newarray([1 ^npoints]),
        point_counter,
        min_y, x, y,
        starting_point, current_point, new_point,
        current_theta, new_theta, smallest_theta,
        current_x, current_y,
        delta_x, delta_y;

    [] -> lines;

    ;;; Convert to array (for speed) and find low-y point on the bounding box

    1 ->> point_counter -> starting_point;
    hd(points)(2) -> min_y;

    until points == nil do
        fast_destpair(points) -> points -> xy;
        xy(1) -> x;
        xy(2) -> y;
        conspoint_record(x,y) -> point_array(point_counter);
        ;;; ASSUMES Y INCREASES DOWN THE SCREEN
        if y > min_y then
            y -> min_y;
            point_counter -> starting_point;
        endif;
        point_counter fi_+ 1 -> point_counter;
    enduntil;

    0 -> current_theta;
    starting_point ->> current_point -> new_point;

    /* Start finding lines... */

    repeat

        two_pi_plus_one -> smallest_theta;

    /* Among the angles that are >= the current angle, select the
        smallest one (and the corresponding point) */

        (point_array(current_point)).Px -> current_x;
        (point_array(current_point)).Py -> current_y;

        fast_for point_counter from 1 to npoints do

            unless point_counter == current_point then

                (point_array(point_counter)).Px - current_x -> delta_x;
                current_y - (point_array(point_counter)).Py -> delta_y;

                normalize(arctan2(delta_x,delta_y)) -> new_theta;

                if (new_theta = 0) and (current_theta > pi) then
                    two_pi -> new_theta;
                endif;

                if new_theta >= current_theta
                and new_theta < smallest_theta then
                    new_theta -> smallest_theta;
                    point_counter -> new_point;
                endif;
            endunless;
        endfast_for;

        ;;; Add new line to the polygon

        conspair([^current_x ^current_y ^((point_array(new_point)).Px)
                ^((point_array(new_point)).Py)], lines) -> lines;

        new_point -> current_point;
        smallest_theta -> current_theta;

        ;;; Keep going until we return to the start
    quitif(new_point==starting_point);

    endrepeat;

enddefine;

endsection;
