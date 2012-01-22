
define plot_rt(net) -> meandata;

    vars a,b,p=1,sum,tabledata, ties=[], rcg_usr_reg, rcg_plt_type;

    read_rt(net) -> tabledata;

    vars meandata = [%
            fast_for a from 1 to 8 do
            mean([% fast_for b from 1 to 8 do
                unless a == b then
                    tabledata(a)(b); tabledata(b)(a);
                else
                    tabledata(a)(b);
                    tabledata(a)(b) :: ties -> ties;
                endunless;
                endfast_for; %]);
            endfast_for; %];

    unless isstring(net) then
        net.pdp3_wtsfile -> net;
    endunless;

    "line" -> rcg_pt_type;
    rc_graphplot({2 3 4 5 6 7 8 9},''><net,meandata,'RT') -> region;
    samegraph();
    "cross" -> rcg_pt_type;
    rc_graphplot({2 3 4 5 6 7 8 9},'',rev(ties),'') -> region;
    newgraph();
enddefine
