vars cascade_rt_safe = true;

define cascade_rt(net,pats) -> RTs;
    vars p,o, time, dev, outfile, outputs, target,
        pat, targ, patname, targ_pos;


    pdp3_adddot(net,'rt') -> outfile;

    if cascade_rt_safe then

        fopen(outfile,"r") -> dev;
        if dev /= false then
            nl(1);
            pr('    CASCADE_RT_SAFE:  RT file found - not overwriting\n');
            pr('    do %rm '><outfile><' first\n\n');
            fclose(dev);
            return
        endif;
    endif;


    fopen(outfile,"w") -> dev;
    [sending output to ^outfile] =>

    ;;;    [ignoring zero] =>
    [time limit ^time_limit] =>
;;;    [USING DK THRESHOLD] =>

    [%
        fast_for p from 2 to Number_of_patterns do

            (pats.pdp3_stimnames)(p) -> patname;
            pdp3_selectpattern(p,pats) -> (pat, targ);
            pdp3_activebit(targ) -> targ_pos;   ;;; the correct product

            pdp3_cascade_start(pat,net) -> activity;

            0 -> time;
            0 -> target;
            1 -> threshold;

            while ( (time<=time_limit) and (target<threshold) ) do
                time + 1 -> time;
                activity -> pdp3_cascade_step(net,0.05) -> activity;
                activity -> pdp3_largestoutput(net) -> (outputs, threshold);
                0.6 -> threshold;
                outputs(targ_pos) -> target;
            endwhile;

            target;     ;;; record actual values

            ;;;        [^patname ^time] =>
            fputstring(dev,''><patname><' '><time);

        endfor; %] -> RTs;

    fclose(dev);

enddefine;
