/*
    PDP3_NEURAL.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Monday 2 December 1991

    Procedures for converting to and from POPLOG-Neural and
    PDP3 format networks and patterns.

*/

if identprops("bp_learn") == undef then
    pr(';;; PDP3 WARNING - PDP3_NEURAL: POPLOG-Neural backprop not loaded\n');
    pr(';;; LOADING IT FOR YOU\n');
    load $pdproot/lib/pdp.p
    uses bp
    pr(';;; END OF WARNING\n');
endif;

define nn_bpnet_to_pdp3(bpnet) -> pdp3_network;

    vars nin = bpnet.bp_ninunits, nout = bpnet.bp_noutunits,
        nhid, hlayers, hidden = bpnet.bp_nhunits, nunits, last_unit;

    vars block, receive_start, receive_length, last_receive,
        send_start, send_length, last_send, biases, netinput,
        weights, senders, lines;

    lvars i, j, wcount, bcount;

    unless isbp_net_record(bpnet) then
        mishap('NN_BPNET_TO_PDP3: Network is not a POPLOG-Neural bp net',
            [^bpnet]);
    endunless;

    0 -> nhid;
    length(hidden) -> hlayers;
    fast_for i from 1 to hlayers do
        nhid + hidden(i) -> nhid;
    endfast_for;

    nin + nhid  -> nunits;
    nunits - 1 -> last_unit;

    newarray([0 ^last_unit 0 ^last_unit],0.0) -> weights;
    newarray([0 ^last_unit],0.0) -> biases;
    newarray([0 ^last_unit],0.0) -> netinput;
    newarray([0 ^last_unit],{}) -> senders;

    0 -> send_start;
    nin -> send_length;

    {% fast_for i from 1 to hlayers do
            send_start+send_length -> receive_start;
            {% receive_start; hidden(i); send_start; send_length; %};
            send_start + send_length -> send_start;
            hidden(i) -> send_length;
         endfast_for;
        %} -> connectivity;

    for block in connectivity using_subscriptor subscrv do

        block(1) -> receive_start;
        block(2) -> receive_length;
        block(3) -> send_start;
        block(4) -> send_length;

        send_start+send_length-1 -> last_send;
        receive_start+receive_length-1 -> last_receive;

        {% fast_for i from send_start to last_send do
                i; endfast_for; %} -> lines;

        fast_for j from receive_start to last_receive do
            copy(lines) -> senders(j);
        endfast_for;

    endfor;

    ;;; WEIGHTS

    1 -> wcount;
    fast_for j from 0 to last_unit do
        for i in senders(j) using_subscriptor subscrv do
            bp_wtarr(bpnet)(wcount) -> weights(i,j);
            wcount fi_+1 -> wcount;
        endfor;
    endfast_for;

    ;;; BIAS

    1 -> bcount;
    fast_for i from nin to last_unit do
        bp_bsarr(bpnet)(bcount) -> biases(i);
        bcount fi_+1 -> bcount;
    endfast_for;

    conspdp3_net_record(bpnet.bp_name, nunits, nin, nout, weights,
        connectivity, senders, netinput, biases) -> pdp3_network;
enddefine;


define pdp3_pats_to_nn(pats) -> (inputs, targets);

    unless ispdp3_pats_record(pats) then
        mishap('PDP3_PATS_TO_NN: Set of PDP3 patterns needed',
            [^pats]);
    endunless;

    vars npats = pats.pdp3_npats, nin = pats.pdp3_inlines,
        nout = pats.pdp3_outlines, stims = pats.pdp3_stims,
        targs = pats.pdp3_targs;

    lvars i,o,p;

    pdp_newarray([1 ^nin 1 ^npats]) -> inputs;
    pdp_newarray([1 ^nout 1 ^npats]) -> targets;

    fast_for p from 1 to npats do
        fast_for i from 1 to nin do
            stims(p,i) -> inputs(i,p);
        endfast_for;
        fast_for o from 1 to nout do
            targs(p,o) -> targets(o,p);
        endfast_for;
    endfast_for;
enddefine;
