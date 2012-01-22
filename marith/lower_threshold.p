
define gather_outputs(net,pats,timen) -> ahist;
    vars nout = pdp3_nout(net), npats = pdp3_npats(pats), activity, p, stim,
        targ, t;

    [recording 'activity:' ^(net.pdp3_wtsfile)
        from 't=1...' ^timen threshold = ^threshold] =>

    vars ahist = newarray([1 ^timen 1 ^npats]);

    fast_for p from 2 to npats do
        [processing ^((pats.pdp3_stimnames)(p))] =>
        pdp3_selectpattern(p,pats) -> (stim, targ);
        pdp3_cascade_start(stim, net) -> activity;
        activity -> reset_response(net);

        fast_for t from 1 to timen do
            activity -> pdp3_cascade_step(net,0.05) -> activity;
            response_mechanism(activity) -> (vector,winner);
            copy(vector) -> ahist(t,p);
        endfast_for;
    endfast_for;
enddefine;


vars correct_product_code = [% fast_for a from 2 to 9 do
    fast_for b from 2 to 9 do
    (a*b) -> product;
    for p from 1 to 36 do
        if product_list(p) = product then quitloop();
        endif;
    endfor;
    p;
    endfast_for;
endfast_for; %];


define lower_threshold(output,pats,threshold) -> errors;
    vars npats = pdp3_npats(pats), correct, stim, targ, p, t,  timen,
        nout = pdp3_outlines(pats), o;

    boundslist(output) --> [1 ?timen 1 ^npats];

    newarray([1 ^npats], procedure(x);
        newarray([1 ^nout],0); endprocedure) -> errors;

    for p from 2 to npats do

        pdp3_selectpattern(p,pats) -> (stim,targ);
        pdp3_largest(targ) -> correct;

        for t from 1 to timen do

            fast_for o from 1 to nout do

                    if output(t,p)(o) > threshold then
                        [t ^t p ^p o ^o ^(errors(p)(o))] =>
                    if correct=o then -1 -> errors(p)(o) else
                       ;;;errors(p)(o) + 1 -> errors(p)(o);
                        1 -> errors(p)(o);
                    endif;
                           nextloop(3);
                    endif;

            endfast_for;
        endfor;
    endfor;

enddefine;
