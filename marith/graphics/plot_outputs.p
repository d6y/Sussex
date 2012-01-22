



vars stimnames = [% fast_for a from 2 to 9 do
        fast_for b from 2 to 9 do
            ''><a><'x'><b; endfor; endfor %];

define get_out_activs(net,pats) -> history;
vars p, stims, targs, activity,history;

{% fast_for p from 2 to pats.pdp3_npats do

    pdp3_selectpattern(p,pats) -> (stim, targs);
    stim -> pdp3_activate(net) -> activity;

    activity -> pdp3_output(net) -> outputs;
    -1 -> outputs(pdp3_largest(targs));
    outputs;

endfast_for; %} -> history;
enddefine;


define get_population_outputs(str,base,n,pats) -> phist;
    vars i, o, history,net,targs,stims,p,activity;
    vars nout = length(product_list);
    vars phist = newarray([1 ^(pats.pdp3_npats)], procedure(x);
        newarray([1 ^nout],0); endprocedure);

    for i from 1 to n do
        [^(base><i)] =>
        pdp3_getweights(str,base><i) -> net;

        fast_for p from 2 to pats.pdp3_npats do
            pdp3_selectpattern(p,pats) -> (stim, targs);
            stim -> pdp3_activate(net) -> activity;
            activity -> pdp3_output(net) -> outputs;

            -1 -> outputs(pdp3_largest(targs));

           fast_for o from 1 to nout do
                outputs(o) + phist(p)(o) -> phist(p)(o);
            endfast_for;

        endfor;

    endfor;


enddefine;

define plot_an_output(net,pats,p);
vars stim, targs,activity;
    pdp3_selectpattern(p,pats) -> (stim, targs);
    stim -> pdp3_activate(net) -> activity;

    if normalize then
        activity -> pdp3_normalizeoutputs(net) -> activity;
    endif;

    activity -> pdp3_output(net) -> activity;

rc_graphplot(1,1,36,'',activity,'') -> region;
enddefine;
