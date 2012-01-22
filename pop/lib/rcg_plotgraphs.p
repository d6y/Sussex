/*
    RCG_PLOTGRAPHS.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Thursday 2 January 1992

    Takes a list containing a vector of y-values to be plotted at
    each x point.

*/

uses rcg;

define rcg_plotgraphs(seq,xlab,ylab,names) -> region;
    vars item, s, e, LargeY, SmallY, data, ls, po;

    2000000 -> SmallY;
    -SmallY -> LargeY;
    length(seq) -> ls;

    ;;; find smallest and largest y-values

    if isarray(seq(1)) then
        boundslist(seq(1)) --> [?s ?e];
    else
        1 -> s; length(seq(1)) -> e;
    endif;

    newarray([^s ^e], procedure(x); []; endprocedure) -> data;

    for item in seq do
        for p from s to e do
            max(item(p),LargeY) -> LargeY;
            min(item(p),SmallY) -> SmallY;
            [^^(data(p)) ^(item(p))] -> data(p);
        endfor;
    endfor;


    newgraph();
    [1 ^ls ^SmallY ^LargeY] -> rcg_usr_reg;

    for p from s to e do
        rc_graphplot(1,1,ls,xlab,data(p),ylab) -> region;
        unless names = false then
            intof((ls/(s+e)) *p) -> po;
            rcg_plt_square(po,data(p)(po));
            rc_print_at(po,data(p)(po),''><names(p-s+1));
        endunless;
        samegraph();
    endfor;
    newgraph();
enddefine;
