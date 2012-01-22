uses rcg_traceplot;
uses rc_ps;

vars prod_list = [% for i in product_list do ''><i; endfor; %];

define trace_chain(net,pats,Prime,Stim,inter) -> history;
    vars history = [], stim, targ, activity, winner, vector, prime;
    vars count, win_time,correct;

    pdp3_selectpattern(Prime,pats) -> (prime, targ);
    pdp3_selectpattern(Stim,pats) -> (stim, targ);
    pdp3_largest(targ) -> correct;

    pdp3_cascade_start(prime,net) -> activity;
    activity -> reset_response(net);

    repeat time_limit times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity -> pdp3_largestnormalizedoutput(net) -> (vector, largest);
        vector :: history -> history;
    endrepeat;


    {% repeat pdp3_inlines(pats) times -1.0; endrepeat %}  -> pdp3_setinput(net,activity) -> activity;


    repeat inter times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity -> pdp3_largestnormalizedoutput(net) -> (vector, largest);
        vector :: history -> history;
    endrepeat;

    pdp3_selectpattern(Stim,pats) -> (prime, targ);
    prime -> pdp3_setinput(net,activity) -> activity;

    0-> count;
    false -> win_time;
    repeat time_limit2 times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity -> pdp3_largestnormalizedoutput(net) -> (vector, largest);
        vector :: history -> history;
        count + 1 -> count;

        if win_time=false and vector(correct) = largest then
            count -> win_time;
        endif;

    endrepeat;

    rev(history) -> history;

rc_postscript('chain2.ps', procedure();

    rcg_traceplot(history,product_list,8);

    region --> [= = = ?y];
    rc_print_at(0,-0.5,''><substring(2,3,''><Prime));
    ;;;    rc_print_at(20,-0.5,net.pdp3_wtsfile);
    ;;;    rc_print_at(0,-1.3,'('><time_limit><' steps)');

    ;;;    rc_jumpto(time_limit,-0.5); rc_print_here(' ISD');
    ;;;    rc_print_at(time_limit,-1.3,'('><inter><' steps)');

    rc_jumpto(time_limit,-0.5);
    rc_drawto(time_limit,y);

    rc_jumpto(time_limit+inter,y);
    rc_print_here(' '><substring(2,3,''><Stim));
    ;;;    rc_drawto(time_limit+inter,0);

    ;;;    rc_print_at(time_limit+inter+win_time,-1,'T='><win_time);

endprocedure, [10 5 0.5 0.5], true);

    ;;;    sort(last(history)) =>
[correct product largest at time ^win_time]=>
enddefine;
