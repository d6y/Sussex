define plot_zrt(net);

    vars a,b,p=1,sum,tabledata;

    read_rt(net) -> tabledata;

    vars data = [% for a from 1 to 8 do for b from 1 to 8 do tabledata(a)(b);
    endfor; endfor; %];

vars meandata = [%
        fast_for a from 1 to 8 do
        mean([% fast_for b from 1 to 8 do
            unless a == b then
            tabledata(a)(b); tabledata(b)(a);
    else
        tabledata(a)(b);
    endunless;
endfast_for; %]);
endfast_for; %];

vars stddev = [% fast_for a from 1 to 8 do
        SD(tabledata(a)) endfast_for; %];

vars mu = mean(data);
vars sd = SD(data);

vars z = [% fast_for a from 1 to 8 do
        (meandata(a)-mu)/sd;
endfast_for; %];

newgraph();
[0 10 -5 5] -> rcg_usr_reg;
"line" -> rcg_pt_type;
rc_graphplot({2 3 4 5 6 7 8 9},'xt',z,'z') -> region;
samegraph();

vars ties = [% fast_for a from 1 to 8 do
        (tabledata(a)(a)-mu)/sd; endfast_for; %];
"cross" -> rcg_pt_type;
rc_graphplot({2 3 4 5 6 7 8 9},'',ties,'') -> region;

unless isstring(net) then
    net.pdp3_wtsfile -> net;
endunless;

rc_print_at(1,2,''><net);

newgraph();
enddefine;
