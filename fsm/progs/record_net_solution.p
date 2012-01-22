

/*

    seq is a list containing a list [operation hiddenvector]

*/

define record_net_solution(net,time_out,threshold,problem) -> seq;

    vars time, key, in_stim, input_string, ov,op, nhid, first_time, hv, av;

    set_problem(problem) -> PAGE;

    init_vars();
    0.0 -> pdp3_mu(net);
    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    1 -> time;
    true -> first_time;
    [%

        repeat

            code_input(first_time, nhid) -> (input_string, in_stim);
            false -> first_time;

            in_stim -> pdp3_activate(net) -> av;
            time + 1 -> time;

            av -> pdp3_hidden(net) -> hv;
            av -> pdp3_output(net) -> ov;

            pdp3_largest(ov) -> unit;

            output_operations(unit)(2) -> op;

            unless ov(unit) < threshold then
                perform_action(op)->;
                [% output_operations(unit)(1); hv; %];
            endunless;

        if op = "done" or time = time_out or ov(unit) < threshold then
            quitloop;
        endif;

    endrepeat;

    %] -> seq;

enddefine;
