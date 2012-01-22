
define net_solve(net, timeout, activity_threshold) -> sequence;

    lvars
        time, input_string, in_stim, first_time, nhid, ov, unit,
        op;

    init_vars();
    0.0 -> pdp3_mu(net);
    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    1 -> time;
    true -> first_time;

    [%

        repeat

            code_input(first_time, nhid) -> (input_string, in_stim);
            false -> first_time;

            in_stim -> pdp3_response(net) -> ov;
            time + 1 -> time;

            pdp3_largest(ov) -> unit;

            output_operations(unit)(2) -> op;

            unless ov(unit) < activity_threshold then
                perform_action(op);
            endunless;

            if op = "done" then
                quitloop;
            elseif time = timeout then
                'TIMEOUT';
                quitloop;
            elseif ov(unit) < activity_threshold then
                'LOW ACTIVITY';
                quitloop;
            endif;

        endrepeat;

    %] -> sequence;

enddefine;
