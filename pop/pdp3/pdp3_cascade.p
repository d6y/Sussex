/*
    PDP3_CASCADE.P

    Author:  Richard Dallaway, September 1991
    Purpose: McClelland's CASCADE model eqs for BP
    Version: Wednesday 12 February 1992
 */

;;; Set net to ZERO state and set pattern

vars pdp3_cascade_external_stim;

define pdp3_cascade_start(pat,net) -> activity;
    lvars nunits = net.pdp3_nunits,i,last_input=(net.pdp3_nin)-1;

    {% repeat nunits times 0; endrepeat; %} ->
        pdp3_activate(net) -> activity;

    pat -> pdp3_setinput(net) -> activity;
    copydata(pat) -> pdp3_cascade_external_stim;

enddefine;

define updaterof pdp3_cascade_prime(primer,pat,net) ->activity;
    lvars i,last_input=(net.pdp3_nin)-1;
    primer -> pdp3_activate(net) -> activity;
    pat -> pdp3_setinput(net) -> activity;
enddefine;


define updaterof pdp3_cascade_step(activity,net,crate) -> activity;
    lvars last_unit = (net.pdp3_nunits)-1, nin = net.pdp3_nin,
        weights = net.pdp3_weights, biases = net.pdp3_biases, bit,
        i, h, netin, drate=1-crate, senders = net.pdp3_senders,
        netinput = net.pdp3_netinput, last_input, an_int = datakey(0),
        mu;

    fast_for h from nin to last_unit do
        biases(h) -> netin;
        for i in senders(h) using_subscriptor subscrv do
            netin + (activity(i) * weights(i,h)) -> netin;
        endfor;
        (crate*netin) + ((netinput(h))*drate) -> netin;
        netin -> netinput(h);
        logistic(netin) ->> activity(h) -> (net.pdp3_activity)(h);
    endfast_for;

    if pdp3_recurrent_cascade then
        ;;; Re-compute the activity of any input units that
        ;;; are acting as context units.
        nin-1 -> last_input;
        pdp3_mu(net) -> mu;
        fast_for i from 0 to last_input do
            pdp3_cascade_external_stim(i fi_+ 1) -> bit;
            if bit < 0 and datakey(bit) = an_int then
                activity(i) * mu  +
                (net.pdp3_activity)(abs(bit)) ->>
                activity(i) -> (net.pdp3_activity)(i);
            else
                bit ->> activity(i) -> (net.pdp3_activity)(i);
            endif;
        endfast_for;
    endif;

enddefine;

vars pdp3_cascade = true;
