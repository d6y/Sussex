/*
    PDP3_RECORDUNITS.P

    Purpose: Utilities for recording activation of pdp3 nets
    Author:  Richard Dallaway, September 1991
    Version: Saturday 23 November 1991
*/


define pdp3_recordunits(net,pats,units) -> vector;
    vars p,dev,u,l,activity,stim,targ,file;

    unless isvector(units) or isarray(units) then
            units -> file;
            pats -> units;
            net -> pats;
            -> net;
    else
        net -> file;
    endunless;

    unless file = false then
        pdp3_adddot(file,'clx') -> file;
        fopen(file,"w") -> dev;
    endunless;


    if length(units) < 1 then
        mishap('PDP3_RECORDUNITS: No units to record',[^units]);
    endif;


    {%
        fast_for p from 1 to pats.pdp3_npats do

            pdp3_selectpattern(p,pats) -> (stim,targ);
            stim -> pdp3_activate(net) -> activity;

            {% for l in units using_subscriptor subscrv do
                    activity(l);

                    unless file = false then
                        finsertstring(dev,''><(activity(l))><' ');
                    endunless;

                endfor; %};

            unless file = false then
                fputstring(dev,'');
            endunless;

        endfast_for; %} -> vector;

    unless file = false then
        fclose(dev);
    endunless;
enddefine;


define pdp3_recordhidden(net,pats) -> vector;
    vars i,file;
    if isstring(pats) or pats = false then
        pats -> file;
        net -> pats;
        -> net;
    else
        net -> file;
    endif;
    pdp3_recordunits(net,pats,
        {% fast_for i from net.pdp3_nin to pdp3_firstoutputunit(net)-1 do
                i; endfast_for; %},file) -> vector;
enddefine;

define pdp3_savestimnames(pats);
    vars p,dev,file=pats;

    if isstring(pats) then
            pats -> file;
    endif;

    pdp3_adddot(file,'nms') -> file;
    fopen(file,"w") -> dev;
    fast_for p from 1 to pats.pdp3_npats do
        fputstring(dev,''><(pats.pdp3_stimnames)(p));
    endfast_for;
    fclose(dev);
enddefine;

define pdp3_recordcascade(net,pats,units,prime,pattern,duration,crate)
        -> vector;

    vars stim, targ, l, activity, dev, p, prime_stim, file;

    if length(units) < 1 then
        mishap('PDP3_RECORDCASCADE: No units to record',[^units]);
    endif;

    if isstring(crate) or crate=false then
        crate -> file;
        duration -> crate;
        pattern -> duration;
        prime -> pattern;
        units -> prime;
        pats -> units;
        net -> pats;
        -> net;
    else
        prime><'-'><pattern -> file;
    endif;

    unless file = false then
        pdp3_adddot(file,'cas') -> file;
        fopen(file,"w") -> dev;
    endunless;

    pdp3_selectpattern(pattern,pats) -> (stim,targ);
    pdp3_selectpattern(prime,pats) -> (prime_stim,targ);
    prime_stim -> pdp3_cascade_prime(stim,net) -> activity;

    {%
        repeat duration times

            {% for l in units using_subscriptor subscrv do
                    activity(l);

                    unless file = false then
                        finsertstring(dev,''><(activity(l))><' ');
                    endunless;

                endfor; %};

            activity -> pdp3_cascade_step(net,crate) -> activity;

            if pdp3_recurrent_cascade then
                stim -> pdp3_setinput(net,activity) -> activity;
            endif;

            unless file = false then
                fputstring(dev,'');
            endunless;

        endrepeat; %} -> vector;

    unless file = false then
        fclose(dev);
    endunless;
enddefine;


define pdp3_recordcascade_hidden(net,pats,prime, pattern,duration,crate)
        -> vector;

    if isstring(crate) or crate=false then
        crate -> file;
        duration -> crate;
        pattern -> duration;
        prime -> pattern;
        pats -> prime;
        net -> pats;
        -> net;
    else
        prime><'-'><pattern -> file;
    endif;
    pdp3_adddot(file,'cas') -> file;
    pdp3_recordcascade(net,pats,
        {% fast_for i from net.pdp3_nin to pdp3_firstoutputunit(net)-1 do
                i; endfast_for; %}, prime, pattern, duration, crate,file)
    -> vector;
enddefine;

define pdp3_getrecordedunits(file) -> vector;

    pdp3_adddot(file,'clx') -> file;
    fopen(file,"r") -> dev;

    if dev = false then
        mishap('PDP3_GETRECORDEDUNITS - Can\'t open file',[^file]);
    endif;

    {%  fgetstring(dev) -> line;
        until line = termin do
            stringtovector(line);
            fgetstring(dev) -> line;
        enduntil; %} -> vector;

    fclose(dev);

enddefine;
