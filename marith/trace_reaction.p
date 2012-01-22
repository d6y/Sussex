uses rcg_traceplot;

vars L = 19;
length(product_list) -> L;
;;; 17 -> L;

vars prod_list = [% for i from 1 to L do product_list(i)><''; endfor; %];

define trace_reaction(net,pats,PATTERN) -> history;
    vars history = [], stim, targ, activity, winner, vector;

    pdp3_selectpattern(PATTERN,pats) -> (stim, targ);
    pdp3_cascade_start(stim,net) -> activity;
    activity -> reset_response(net);

    repeat time_limit times
        activity -> pdp3_cascade_step(net,0.05) -> activity;
        activity -> pdp3_largestnormalizedoutput(net) -> (vector, largest);
    {% for i from 1 to L do vector(i); endfor; %} :: history -> history;
    endrepeat;

    rev(history) -> history;
;;;rc_postscript('~/papers/postscript/p4x4_01.ps', procedure();
XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-220-*-*-p-*-iso8859-1')->;
rcg_traceplot(history,prod_list,12);
;;;endprocedure, [5 5 0.5 0.5], true);

;;;    rc_print_at(0,0,PATTERN><'');
;;;    rc_print_at(5,0,net.pdp3_wtsfile);
;;;    rc_print_at(15,0,time_limit><' steps');

;;;    sort(last(history)) =>

enddefine;
