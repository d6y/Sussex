
3000000 ->  popmemlim;
vars region;
uses popxlib
uses rc_graphplot2
;;; rc_start();

;;; XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-120-*-*-p-*-iso8859-1')->;

define newgraph;
    true -> rcg_newgraph;       ;;; clear the window for each graph
    undef -> rcg_usr_reg;       ;;; find region from the data
    0.1 -> rcg_win_reg;         ;;; map onto window
enddefine;

define samegraph;
    false -> rcg_newgraph;      ;;; don't clear the window
    region -> rcg_usr_reg;      ;;; use same axes as before
    undef -> rcg_win_reg;       ;;; use same bit of window as before
enddefine;


define graphoff;
    false -> rcg_newgraph;  ;;; don't clear window
    false -> rcg_pt_type;   ;;; don't plot data
    false -> rcg_ax_type;   ;;; don't draw axes
    undef -> rcg_win_reg;   ;;; don't change scale
enddefine;

define graphon;
    true -> rcg_newgraph;
    "line" -> rcg_pt_type;
    "axes" -> rcg_ax_type;
    0.1 -> rcg_win_reg;
enddefine;

define newpaper -> old_window;
    rc_window -> old_window;
    false -> rc_window;     ;;; make a new one on the next call
    rc_window_x + rc_window_xsize -> rc_window_x;
    rc_start();             ;;; create the new window
enddefine;

define lineandcrossplotting;
    procedure(x,y);
        rc_drawto(x,y); rcg_plt_cross(x,y); endprocedure
        -> rcg_pt_type;
enddefine;

define lineandsquareplotting;
    procedure(x,y);
        rc_drawto(x,y); rcg_plt_square(x,y); endprocedure
        -> rcg_pt_type;
enddefine;


define rcg_plt_box(x,y);
    ;;; Draw a FILLED-IN square,
    lvars x y;
    lvars side  = round(abs(rcg_pt_cs));
    if x.isreal and y.isreal then
    XpwFillRectangle(rc_window,
        rc_transxyout(x-((side/rc_xscale)/2), y-((side/rc_yscale)/2)),
        side, side);
    endif;
enddefine;


define rc_fill_rectangle(x,y,dx,dy);
    lvars x y;
    XpwFillRectangle(rc_window,
        rc_transxyout(x,y), dx, dy);
enddefine;


vars rcp_fill_rectangle;

define rcg_plt_box2(x,y);
    lvars side  = round(abs(rcg_pt_cs));
    rc_transxyout(x,y) -> (x,y);
    rcp_fill_rectangle(x,y,side,side);
enddefine;

define rcg_plt_circle(x,y);
    ;;; Draws a cirlce at x,y
    lvars x,y;
    lvars offset = rcg_pt_cs/2;
    round(x - offset) -> x;
    round(y - offset) -> y;
    XpwDrawArc(rc_window,x,y,rcg_pt_cs,rcg_pt_cs,0,360*64);
enddefine;

define rcg_plt_bullet(x,y);
    ;;; Draws a filled-in cirlce at x,y
    rc_transxyout(x,y) -> (x,y);
    lvars offset = rcg_pt_cs/2;
    round(x - offset) -> x;
    round(y - offset) -> y;
    XpwFillArc(rc_window,x,y,rcg_pt_cs,rcg_pt_cs,0,360*64);
enddefine;

define rcg_plt_bullet2(x,y);
    (x - (rcg_pt_cs/rc_xscale)/2) -> x;
    (y - (rcg_pt_cs/rc_yscale)/2) -> y;
    rc_draw_arc(x,y,rcg_pt_cs/rc_xscale,rcg_pt_cs/rc_yscale,0,360*64);
enddefine;
/*
rc_draw_arc(4,200,7/rc_xscale,7/rc_yscale,0,360*64);
*/
vars rcg_plt_sdbar_width = 0.1;

define rcg_plt_bars(x,y,one_sd,mark_proc);
    ;;; Plots a MARK_PROC at (x,y) and adds deviation bars of
    ;;; ONE_SD above and bellow
    lvars height = one_sd;
    lvars x,y;

    rc_jumpto(x,y-height);     ;;; strut of the SD marker
    rc_drawto(x,y+height);

    rc_jumpto(x-rcg_plt_sdbar_width,y-height);       ;;; ornaments
    rc_drawto(x+rcg_plt_sdbar_width,y-height);
    rc_jumpto(x-rcg_plt_sdbar_width,y+height);
    rc_drawto(x+rcg_plt_sdbar_width,y+height);

    mark_proc(x,y);
enddefine;


define rc_default;
    500 ->> rc_window_xsize -> rc_window_ysize;
    520 -> rc_window_x;
    300 -> rc_window_y;
    1 -> rc_xscale;
    -1 -> rc_yscale;
    0 ->> rc_xposition ->> rc_yposition -> rc_heading;
    false -> rc_clipping;
    0 ->> rc_xmin -> rc_ymin;
    rc_window_xsize -> rc_xmax;
    rc_window_ysize -> rc_ymax;
    250 ->> rc_xorigin -> rc_yorigin;
enddefine;


vars rcg=true;
