uses rcg_traceplot;

define hidden_units_names(net);
vars out1 = pdp3_firstoutputunit(net)-1, nin = pdp3_nin(net),h;
[% fast_for h from nin to out1 do h; endfast_for; %];
enddefine;

define trace_hidden(net,pats,PATTERN) -> history;
    vars history = [], stim, targ, activity, winner, vector;

    pdp3_selectpattern(PATTERN,pats) -> (stim, targ);
    pdp3_cascade_start(stim,net) -> activity;


    repeat time_limit times

        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity  -> pdp3_hidden(net) -> vector;
        vector :: history -> history;

    endrepeat;

    rev(history) -> history;
    rcg_traceplot(history,hidden_units_names(net),10);
    rc_print_at(0,0,PATTERN><'');
    rc_print_at(5,0,net.pdp3_wtsfile);
    rc_print_at(15,0,time_limit><' steps');

;;;    sort(last(history)) =>

enddefine;
