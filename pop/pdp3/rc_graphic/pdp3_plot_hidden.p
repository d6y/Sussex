uses rcg_unitplot;

pdp3_plot_hidden(net,pats,10);

define pdp3_plot_hidden(net,pats,scale);
vars acts;

    pats -> pdp3_activities(net) -> acts;
    rcg_unitplot([% for a in acts using_subscriptor subscrv do
            a -> pdp3_hidden(net); endfor; %], pdp3_stimnames(pats), scale);

enddefine;
