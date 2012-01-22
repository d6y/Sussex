uses rcg_traceplot;

define trace_reaction2(net,stim);
    vars history = [], activity, winner, vector;

    pdp3_cascade_start(stim,net) -> activity;
    activity -> reset_response(net);

    repeat time_limit times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        response_mechanism(activity) -> (vector,winner);
        vector :: history -> history;
    endrepeat;

    rev(history) -> history;
    rcg_traceplot(history,product_list,14);

enddefine;
