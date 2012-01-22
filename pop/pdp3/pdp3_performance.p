/*

    PDP3_PERFORMANCE.P

    Purpose: Tests the performance of PDP3 networks
    Author:  Richard Dallaway, Nov 21 1991
    Version: Thursday 16 July 1992
 */

define updaterof pdp3_performance(pats,net,region)
        -> (tss,pc,err_list,pss_list);

    vars npats = pats.pdp3_npats, os, bit_error, correct,
        stim, targ, p, h, o, ss, pc=0, err_list = [], nout = net.pdp3_nout,
        tss=0, pss, large, tie, target_value;

    [% fast_for p from 1 to npats do

            pdp3_selectpattern(p,pats) -> (stim,targ);
            stim -> pdp3_response(net) -> os;

            0 -> pss;
            true -> correct;
            1 -> large;
            false -> tie;

            fast_for o from 1 to nout do

                targ(o) -> target_value;

                if target_value >= 0 then ;;; don't care about -ve targets

                    if target_value = 1 then
                        pdp3_tmax(net) -> target_value;
                    elseif target_value = 0 then
                        1-pdp3_tmax(net) -> target_value;
                    endif;

                    (target_value-os(o)) -> bit_error;

                    if region = "largest" then
                        if os(o) > os(large) then
                            o -> large;
                            false -> tie;
                        elseif os(o) = os(large) and o/=large then
                            true -> tie;
                        endif;
                    elseif isnumber(region) then
                        if abs(bit_error) > region then
                            false -> correct;
                        endif;
                    else
                        mishap('PDP3_PERFORMANCE: Unknown error measure',
                            [^region]);
                    endif;

                    (bit_error**2) + pss -> pss;

                endif;

            endfast_for;

            if region = "largest" then
                if large /= pdp3_activebit(targ) then
                    false -> correct;
                endif;
                if tie then
                    [TIE FOR MOST ACTIVE BIT] =>
                    os=>
                endif;
            endif;

            pss + tss -> tss;
            [% (pats.pdp3_stimnames)(p); pss;%];

            unless correct then
                ((pats.pdp3_stimnames)(p)) :: err_list -> err_list;
            else
                pc + 1 -> pc;
            endunless;

        endfast_for; %] -> pss_list;

    100.0 * pc / npats -> pc;
enddefine;

define updaterof pdp3_wrongresponse(pats,net,region) -> err_list;

    vars npats = pats.pdp3_npats, os, bit_error, correct,
        stim, targ, p, h, o, ss, pc=0, err_list = [], nout = net.pdp3_nout,
        tss=0, pss, large, tie;

    [% fast_for p from 1 to npats do

            pdp3_selectpattern(p,pats) -> (stim,targ);
            stim -> pdp3_response(net) -> os;

            true -> correct;
            1 -> large;
            false -> tie;

            fast_for o from 1 to nout do
                (targ(o)-os(o)) -> bit_error;

                if region = "largest" then
                    if os(o) > os(large) then
                        o -> large;
                        false -> tie;
                    elseif os(o) = os(large) then
                        true -> tie;
                    endif;
                else
                    if abs(bit_error) > region then
                        false -> correct;
                    endif;
                endif;

            endfast_for;

            if region = "largest" then
                if large /= pdp3_activebit(targ) then
                    false -> correct;
                endif;
                if tie then
                    [TIE FOR MOST ACTIVE BIT] =>
                    os=>
                endif;
            endif;

            unless correct then
                ((pats.pdp3_stimnames)(p)) :: err_list -> err_list;
            endunless;

        endfast_for; %] -> err_list;

enddefine;
