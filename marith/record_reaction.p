
define record_reaction(net,pats,PATTERN) -> history;
    vars history = [], stim, targ, activity, winner, vector;

    pdp3_selectpattern(PATTERN,pats) -> (stim, targ);
    pdp3_cascade_start(stim,net) -> activity;
    activity -> reset_response(net);

    repeat time_limit times

        activity -> pdp3_cascade_step(net,0.05) -> activity;
        response_mechanism(activity) -> (vector,winner);
        vector :: history -> history;

    endrepeat;

    rev(history) -> history;

enddefine;
