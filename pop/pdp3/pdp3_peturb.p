/*
    PDP3_PETURB.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Monday 13 January 1992

    Peturb weights of a network (returns new network).
*/


define pdp3_peturb_destroy(v,extent) -> v;
    unless random(1.0) > extent then
        0 -> v;
    endunless;
enddefine;

define pdp3_peturb_absolute(v,extent) -> v;
    v + random(extent)-(extent/2) -> v;
enddefine;

define pdp3_petrub_relative(v,extent) -> v;
    v + v*(random(extent)-(extent/2)) -> v;
enddefine;

define pdp3_peturb(net,extent,type) -> net;

    ;;;pdp3_copynet(net) -> net;

    extent * 1.0 -> extent;     ;;; coerce to float (stop random(1) when
                                ;;; random(1.0) was intended).

    lvars last_unit = net.pdp3_nunits-1, senders = net.pdp3_senders,
        weights = net.pdp3_weights, biases = net.pdp3_biases,
        i, h, nin = net.pdp3_nin, last_input = nin-1;
    vars damage;

    if type = "destroy" then
        pdp3_peturb_destroy -> damage;
    elseif type = "absolute" then
        pdp3_peturb_absolute -> damage;
    elseif type = "relative" then
         pdp3_petrub_relative -> damage;
    else
        mishap('PDP3_PETURB: Requesting undefined kind of damage',[^type]);
    endif;

    fast_for h from nin to last_unit do
        damage(biases(h),extent) -> biases(h);
        for i in senders(h) using_subscriptor subscrv do
            damage(weights(i,h),extent) -> weights(i,h);
        endfor;
    endfast_for;
enddefine;


define pdp3_destroy(oldnet,unit) -> net;
    vars last_unit=(net.pdp3_nunits)-1,weight;
    lvars u;

    if unit > last_unit or unit < 0 then
        mishap('PDP3_DESTROY: Requested unit does not exist',[^unit]);
    endif;

;;;    pdp3_copynet(oldnet) -> net;
    oldnet -> net;
    net.pdp3_weights -> weight;

    0 -> (net.pdp3_biases)(unit);
    fast_for u from 0 to last_unit do
        0 ->> weight(u,unit) -> weight(unit,u);
    endfast_for;

enddefine;
