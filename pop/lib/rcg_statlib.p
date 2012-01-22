/*  RCG_STATLIB.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Some useful graphics routines for PDP and psychology.
    See also: statlib.p


         CONTENTS - (Use <ENTER> g to access required sections)

 -- RCG_BOXPLOT(data, title)
 -- RCG_BARCHART(vector)
 -- RCG_SCATTERGRAM(X,Y) -> (a,b); Scatter plus regres.line (y from x)

*/

uses statlib;
vars region;
uses rcg;

/*
-- RCG_BOXPLOT(data, title) -------------------------------------------
*/
uses rcg_boxplot;


/*
-- RCG_BARCHART(vector) -----------------------------------------------
*/
uses rcg_barchart;

/*
-- RCG_SCATTERGRAM(X,Y) -> (a,b); Scatter plus regres.line (y from x)

    Plots a scatter diagram for X and Y, and draws a regression line
    (assuming y predicted from x).  Returns:
        a - the intercept    and    b - the slope


    NB. See also SHOWLIB * LINEARFIT

*/

define constant procedure rcg_scattergram(x,y) -> (a,b);
    vars y_bar, x_bar, cov, s2x, string, x1,x2,y2, rcg_pt_type,
    pop_pr_places=2;
    "cross" -> rcg_pt_type;
    rc_graphplot(x,'x',y,'y') -> region;
    region --> [?x1 ?x2 = ?y2];
    mean(y) -> y_bar;
    mean(x) -> x_bar;
    covariance(x,y) -> cov;
    variance(x) -> s2x;

    cov/s2x * 1.0-> b;
    y_bar- b*x_bar * 1.0 -> a;
    if a < 0 then
        'y='><b><'x'><a -> string;
    else;
        'y='><b><'x+'><a -> string;
    endif;

    samegraph();
    "line" -> rcg_pt_type;
    rc_jumpto(x1,b*x1+a);
    rc_drawto(x2,b*x2+a);
    rc_print_at(x1+abs((x2-x1))*0.1,y2,string);
    newgraph();
enddefine;



vars rcg_statlib=true;
