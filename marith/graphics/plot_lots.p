load genmean.p

vars base, pats = pdp3_getpatterns('tt',65,16,31), s, n, net;

vars xp = 1, x = [0.26 3 6 9 0.26 3 6 9 ],
    y = [0.25 0.25 0.25 0.25 3 3 3 3];
vars xo = 1, yo = 1;

3 -> rcg_pt_cs;

for s in [emrp rp] do
    1 -> xp;
    true -> rcg_newgraph;
    for base in  ['for' ] do

        for n in [5 6 7 8 9 10 15 20] do

            [inches ^(x(xp)) ^(x(xp)+2) ^(y(xp)+2) ^(y(xp))] -> rcg_win_reg;
            genmean(base><s><n><'-',5);
            xp + 1 -> xp;

            false->rcg_newgraph;
        endfor;
    endfor;
        readline() =>
endfor;
