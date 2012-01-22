
define plot_reaction(net,pats,PATTERN);
    vars history = [], stim, targ, win, activity, output, won;

    pdp3_selectpattern(PATTERN,pats) -> (stim, targ);
    pdp3_activebit(targ) -> win;
    pdp3_cascade_start(stim,net) -> activity;
    activity -> reset_response(net);

    repeat time_limit times

        activity -> pdp3_cascade_step(net,0.05) -> activity;
        response_mechanism(activity) -> (output,won);
        (output(win)) :: history -> history;

    endrepeat;

    newgraph();
    "line" -> rcg_pt_type;
    rc_graphplot(1,1,time_limit,'time',rev(history),'response') -> region;
    rc_print_at(10,0.5,PATTERN);

enddefine;
