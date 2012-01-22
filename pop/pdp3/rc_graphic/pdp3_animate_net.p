uses rcg_unitplot;


define pdp3_animate_net(net,pats, scale);
    vars p, npats, x,y, nin, nout, layers, naming;

    pdp3_npats(pats) -> npats;
    pdp3_nin(net) -> nin;
    pdp3_nout(net) -> nout;

    for p from 1 to npats do

        pdp3_selectpattern(p,pats) -> (stim, targ);
        stim -> pdp3_activate(net) -> acts;

        [%  [% fast_for i from 1 to nin do acts(i); endfast_for; %];
            acts -> pdp3_hidden(net);
            acts -> pdp3_output(net); %] -> layers;

        rcg_unitplot(layers, [input hidden output], scale);

        region --> [?x = ?y =];
        rc_print_at(x,y,(pdp3_stimnames(pats)(p))><' -- tap a key');
        until vedscr_input_waiting()/= false do ; enduntil;
        vedscr_read_ascii() ->;

    endfor;

enddefine;
