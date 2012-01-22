;;; load program.p


/*

vars seq, reason, net;

vars net = pdp3_getweights('networks/fsm35','weights/303a-3');

set_problem([+ 11 1]) -> PAGE;
PAGE ==>
rt_runnet(net,50,200,0.45) -> (seq, reason);
reason =>
PAGE ==>
*/


define rt_runnet(net,MaxTime,max_rt,threshold) -> (Seq, reason);
    vars time, key, in_stim, input_string, ov,op, nhid, first_time,rt;

    init_vars();
    0.0 -> pdp3_mu(net);
    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    true -> pdp3_recurrent_cascade;
    1 -> time;
    true -> first_time;
    [%
        repeat

            code_input(first_time, nhid) -> (input_string, in_stim);
            false -> first_time;

            0 -> rt;
            time + 1 -> time;


/*
            in_stim -> pdp3_response(net) -> ov;
            time + 1 -> time;

            pdp3_largest(ov) -> unit;

            output_operations(unit)(2) -> op;
            unless ov(unit) < threshold then
;;;                pr_array(ov);
                [largest is unit ^unit at ^(ov(unit)) ^op]=>
perform_action(op)->;
            else
[below thresh] =>
                false -> op;
            endunless;
*/

pdp3_cascade_start(in_stim,net) -> activity;

            for i from First_hidden_unit to Last_output_unit do
                -0.5 -> pdp3_netinput(net)(i);
            endfor;

            repeat
                activity -> pdp3_cascade_step(net,0.05) -> activity;
                activity -> pdp3_output(net) -> ov;
                pdp3_largest(ov) -> unit;
[largest ^unit ^(ov(unit))]=>
                if ov(unit) > threshold then quitloop; endif;
                rt + 1 -> rt;
                if rt > max_rt then quitloop; endif;
            endrepeat;

            if rt > max_rt then
                false -> op;
            else
                output_operations(unit)(2) -> op;
                perform_action(op)->;
                [time ^time rt ^rt op ^op] =>
                [^time ^rt];
            endif;

        if op = "done" then
                'Finished' -> reason; quitloop;
            elseif time = MaxTime then
                'Time out' -> reason; quitloop;
            elseif op = false then
                'Threshold not reached' -> reason; quitloop;
            endif;

        endrepeat;

    %] -> Seq;

enddefine;
