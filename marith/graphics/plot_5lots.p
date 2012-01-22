
vars base, pats = pdp3_getpatterns('tt',65,16,31), s, n, net;

vars xp = 1, x = [0.26 3 6 0.26 3 6], y = [0.25 0.25 0.25 3 3 3 ];
vars xo = 1, yo = 1;

3 -> rcg_pt_cs;

for base in ['for' 'alp'] do

    5 -> n;

    true -> rcg_newgraph;
        1 -> xp;
    for s in [cl emcl emrp clrp emclrp rp] do


        [inches ^(x(xp)) ^(x(xp)+2) ^(y(xp)+2) ^(y(xp))] -> rcg_win_reg;
        genmean(base><s><n><'-',5);
        xp + 1 -> xp;

        false->rcg_newgraph;

    endfor;

    readline() =>

endfor;
