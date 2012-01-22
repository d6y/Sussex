uses rcg;
uses rcg_hinton;

define rc_plot_array(a,scale,gap,cols,rows);

    vars x1,x2,y1,y2,name;
    lvars x,y,v, x0, y0, sx, sy;

    rc_default();
    rc_start();

    -200 -> x0;
    200 -> y0;

    0 ->> sx -> sy;

    for name in cols do
        rc_print_at(x0+sx,y0+2*gap,''><name);
        sx+gap -> sx;
    endfor;

    for name in rows do
        rc_print_at(x0-(2*gap),y0-sy,''><name);
        sy + gap -> sy;
    endfor;

    0 -> sx;

    boundslist(a) --> [?x1 ?x2 ?y1 ?y2];

    fast_for x from x1 to x2 do
        0 -> sy;
        fast_for y from y1 to y2 do

            a(x,y)*scale -> v;
            plt_hinton(x0+sx,y0-sy,v);
            sy + gap -> sy;

        endfast_for;
        sx + gap -> sx;
    endfast_for;

enddefine;
