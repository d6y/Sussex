/*
    PDP3_ACTIVATE.P

    Author:  Richard Dallaway, September 1991
    Purpose: Activate pdp3 network
    Version: Saturday 8 May 1993
 */

define pdp3_multiply(a,w) -> n;
    lvars a,w,n;
    a * w -> n;
enddefine;


;;; set input pattern
define updaterof pdp3_setinput(pat,net) -> activity;
    lvars i, bit, last_input, last_unit, an_int = datakey(0);
    vars mu;

    if ispdp3_net_record(net) then
        pdp3_nunits(net) - 1 -> last_unit;
        newarray([0 ^last_unit],0.0) -> activity;
    else
        net -> activity;
        pat -> net;
            -> pat;
    endif;

    pdp3_nin(net) - 1 -> last_input;
    pdp3_mu(net) -> mu;

    fast_for i from 0 to last_input do
        pat(i fi_+ 1) -> bit;
        if bit < 0 and datakey(bit) = an_int then
            activity(i) * mu  +
            (net.pdp3_activity)(abs(bit)) ->>
            activity(i) -> (net.pdp3_activity)(i);
        else
            bit ->> activity(i) -> (net.pdp3_activity)(i);
        endif;
    endfast_for;
enddefine;

define updaterof pdp3_activate(pat,net) -> activity;
    lvars last_unit = net.pdp3_nunits-1, senders = net.pdp3_senders,
        weights = net.pdp3_weights, biases = net.pdp3_biases,
        activity, i, h, netin, nin = net.pdp3_nin, last_input = nin-1;

    pat -> pdp3_setinput(net) -> activity;

    fast_for h from nin to last_unit do
        biases(h) -> netin;
        for i in senders(h) using_subscriptor subscrv do
        netin + pdp3_multiply(activity(i),weights(i,h)) -> netin;
        endfor;
        netin -> (net.pdp3_netinput)(h);
        logistic(netin) ->> activity(h) -> (net.pdp3_activity)(h);
    endfast_for;
enddefine;


define updaterof pdp3_activateoutput(hidpat,net); /* -> output */
    lvars last_unit = net.pdp3_nunits-1, senders = net.pdp3_senders,
        weights = net.pdp3_weights, biases = net.pdp3_biases,
         first_output = pdp3_firstoutputunit(net), i, h, netin,
         offset = pdp3_nin(net)-1;

    {% fast_for h from first_output to last_unit do
        biases(h) -> netin;
        for i in senders(h) using_subscriptor subscrv do
            netin + (hidpat(i-offset) * weights(i,h)) -> netin;
        endfor;
        netin -> (net.pdp3_netinput)(h);
        logistic(netin);
    endfast_for; %}
enddefine;


define pdp3_largest(vector) -> win;
    vars i,s,e,win;
    if isarray(vector) then
        boundslist(vector) --> [?s ?e];
    else
        1 -> s;
        length(vector) -> e;
    endif;
    s -> win;
    fast_for i from s+1 to e do
        if vector(i) > vector(win) then
            i -> win;
        endif;
    endfast_for;
enddefine;

define pdp3_activebit(vect) -> bit;
    vars i,s=1,e,bit=false;

    if isarray(vect) then
        boundslist(vect) --> [?s ?e];
    else
        length(vect) -> e;
    endif;

    fast_for i from s to e do
        if vect(i) = 1 then
            i -> bit;
            quitloop;
        endif;
    endfast_for;

    if bit = false then
        mishap('PDP3_ACTIVEBIT: No active bit found',[^vect]);
    endif;
enddefine;


define updaterof pdp3_sumoutputs(a,net) -> sum;
    vars o, sum=0;
    fast_for o from pdp3_firstoutputunit(net) to net.pdp3_nunits fi_- 1 do
        a(o) + sum -> sum;
    endfast_for;
enddefine;

define updaterof pdp3_normalizeoutputs(a,net) -> a;
    vars o, sum=0, out1, outn;
    pdp3_firstoutputunit(net) -> out1;
    pdp3_nunits(net) fi_- 1 -> outn;
    fast_for o from out1 to outn do
        a(o) + sum -> sum;
    endfast_for;
    fast_for o from out1 to outn do
        a(o)/sum -> a(o);
    endfast_for;
enddefine;


define updaterof pdp3_largestnormalizedoutput(a,net) -> (outputs, large);
    vars v,out1, outn;
    lvars o, sum=0;
    0 -> large;
    pdp3_firstoutputunit(net) -> out1;
    pdp3_nunits(net) fi_- 1 -> outn;
    fast_for o from out1 to outn do
        a(o) + sum -> sum;
    endfast_for;
    {% fast_for o from out1 to outn do
        a(o)/sum ->> v;
        max(large,v) -> large;
    endfast_for; %} -> outputs;
enddefine;


define updaterof pdp3_largestnormalizedsquareoutputs(a,net) -> (outputs, large);
    vars v,out1, outn;
    lvars o, sum=0;
    0 -> large;
    pdp3_firstoutputunit(net) -> out1;
    pdp3_nunits(net) fi_- 1 -> outn;
    fast_for o from out1 to outn do
        (a(o)**2) + sum -> sum;
    endfast_for;
    sqrt(sum) -> sum;
    {% fast_for o from out1 to outn do
        a(o)/sum ->> v;
        max(large,v) -> large;
    endfast_for; %} -> outputs;
enddefine;


define updaterof pdp3_largestoutput(a,net) -> (outputs, large);
    vars v,out1, outn;
    lvars o;
    0 -> large;
    pdp3_firstoutputunit(net) -> out1;
    pdp3_nunits(net) fi_- 1 -> outn;
    {% fast_for o from out1 to outn do
        a(o) ->> v;
        max(large,v) -> large;
    endfast_for; %} -> outputs;
enddefine;


define updaterof pdp3_threshold(a,net,t);
    vars o, out1, outn;
    pdp3_firstoutputunit(net) -> out1;
    pdp3_nunits(net) fi_- 1 -> outn;
    {% fast_for o from out1 to outn do
        if a(o) > t then 1; else 0; endif;
    endfast_for; %};
enddefine;

define updaterof pdp3_output(act,net);
    vars i;
    {% fast_for i from pdp3_firstoutputunit(net) to (net.pdp3_nunits)-1 do
            act(i) endfast_for;%};
enddefine;

define updaterof pdp3_hidden(act,net);
    vars i;
   {% fast_for i from pdp3_nin(net) to pdp3_nunits(net)-pdp3_nout(net)-1 do
        act(i); endfast_for; %};
enddefine;

define updaterof pdp3_netinputvalue(value,net);
    vars p, nunits = (net.pdp3_nunits)-1, struct=net.pdp3_netinput;
    fast_for p from 0 to nunits do
        value -> struct(p);
    endfast_for;
enddefine;

define updaterof pdp3_response(stim,net); /* -> response */
    stim -> pdp3_activate(net) -> pdp3_output(net);
enddefine;

define updaterof pdp3_responses(pats,net); /* -> responses */
    lvars p;
    vars stim, targ, p1, pn;

    if ispdp3_net_record(net) then  ;;; default: all patterns
        1 -> p1;
        pats.pdp3_npats -> pn;
    else

        net -> p1;
        pats -> net;

        if ispdp3_net_record(net) then  ;;; sequence

                -> pats;

            pdp3_seqstart(pats) -> seq;
            seq(p1) -> p1;

            if seq matches [== ^p1 ?pn ==] then
                pn - 1 -> pn;
            else
                pdp3_npats(pats) -> pn;
            endif;;

        0.0 -> pdp3_inputactivation(net);

        else ;;; start and stop specified

            p1 -> pn;
            pats -> p1;
                -> net;
                -> pats;
        endif;
    endif;

    {% fast_for p from p1 to pn do
            pdp3_selectpattern(p,pats) -> (stim, targ);
            stim -> pdp3_response(net);
        endfast_for; %};
enddefine;

define updaterof pdp3_activities(pats,net); /* -> activities */
    lvars p;
    vars stim, targ, p1, pn;

    if ispdp3_net_record(net) then  ;;; default: all patterns
        1 -> p1;
        pats.pdp3_npats -> pn;
    else

        net -> p1;
        pats -> net;

        if ispdp3_net_record(net) then  ;;; sequence

                -> pats;

            pdp3_seqstart(pats) -> seq;
            seq(p1) -> p1;

            if seq matches [== ^p1 ?pn ==] then
                pn - 1 -> pn;
            else
                pdp3_npats(pats) -> pn;
            endif;;

        ;;; User may not want ZERO
        ;;; 0.0 -> pdp3_inputactivation(net);

        else ;;; start and stop specified

            p1 -> pn;
            pats -> p1;
                -> net;
                -> pats;
        endif;
    endif;



    {% fast_for p from p1 to pn do
            pdp3_selectpattern(p,pats) -> (stim, targ);
            stim -> pdp3_activate(net);
        endfast_for; %};
enddefine;
