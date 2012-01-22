
define plot_hidden_reaction(net,pats,PATTERN);
    vars i, history = [], stim, targ, activity, hidden;

    pdp3_selectpattern(PATTERN,pats) -> (stim, targ);
    pdp3_cascade_start(stim,net) -> activity;

    repeat time_limit times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity -> pdp3_hidden(net) -> hidden;
        hidden :: history -> history;
    endrepeat;

    rcg_plotgraphs(rev(history),'Time ('><PATTERN><')','Hidden',
        [% for hidden from First_hidden_unit to Last_hidden_unit do
            hidden; endfor; %]) -> region;


enddefine;
