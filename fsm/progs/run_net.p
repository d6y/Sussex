vars threshold = 0.25;

define vedprob(P);
    vars i,j, vedstatic=false;
    for i in P do
        for j in i do
            vedinsertstring(j><' ');
        endfor; vedinsertstring('\n');
    endfor;
enddefine;


define vedprobdiff(P,P0);
    vars i,j, vedstatic = true;
    for i from 1 to length(P) do
        for j from 1 to length(P(i)) do
            if P(i)(j) /= P0(i)(j) then
                vedjumpto(3+i,(j*2)-1);
                vedinsertstring(P(i)(j)><'');
            endif;
        endfor;
    endfor;
enddefine;


define run_net(net,numbers, show, MaxTime) -> Seq;
    vars time, key, in_stim, input_string, ov,op, nhid,
        vedstatic=false, first_time;

    init_vars();
    0.0 -> pdp3_mu(net);

    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    set_problem(numbers) -> PAGE;

    if show then
        vededitor(vedhelpdefaults, 'screen_'><sys_fname_nam(net.pdp3_wtsfile));
        if wved_should_warp_mouse("vedfileselect") then
            ;;; change input window so that it will change back later
            wved_set_input_focus(wvedwindow)
        endif;
        true -> vedstatic;

        vedjumpto(4,1);
        vedprob(PAGE);
        length(PAGE(1))+1 -> width;
    endif;

    0 -> time;
    true -> first_time;
    [% repeat
            if show then
                vedjumpto(1,40); vedinsertstring('Tap a key t='><time);
            endif;

            if show and isnumber(ROW) and isnumber(COLUMN) then
                unless ROW < 1 or COLUMN < 1 then
                    vedjumpto(3,50); vedinsertstring('        ');
                    vedjumpto(3,40);
                    vedinsertstring('r'><ROW><'c'><COLUMN><'    ');
                    vedjumpto(3+ROW,((width-COLUMN)*2)-1);
                    vedinsertstring(PAGE(ROW)(width-COLUMN)><'');
                endunless;
            endif;

            if show then
                until vedscr_input_waiting()/= false do ; enduntil;
                vedscr_read_ascii() ->key;
            endif;

            code_input(first_time, nhid) -> (input_string, in_stim);
            false -> first_time;

            if show then
                vedjumpto(2,40); vedinsertstring('Mark: '><input_string><'   ');
            endif;

            in_stim -> pdp3_response(net) -> ov;

            time + 1 -> time;

            pdp3_largest(ov) -> unit;
            output_operations(unit)(2) -> op;

            if show then
                vedjumpto(1,1);
                vedinsertstring('Operation: '><op><'                         ');
                vedjumpto(2,1);

                vedjumpto(4,1);
                copytree(PAGE) -> P0;
            endif;

            unless ov(unit) < threshold then

                if op = "mark_carry" then
                    tens();
                endif;

                popval([^op (); ]);

                if show then
                    vedprobdiff(PAGE,P0);
                endif;

            endunless;

            if op = "done" or time = MaxTime
            or ov(unit) < threshold then quitloop; endif;
        endrepeat;

        if time = MaxTime then "TIMEOUT"; MaxTime;
        elseif ov(unit) < threshold then "THRESHOLD"; ov(unit);
        endif;

    %] -> Seq;

    if show then
        vedjumpto(1,40);
        vedinsertstring(' Done t='><time><'   ** TAP A KEY TO QUIT ** ');
        until vedscr_input_waiting()/= false do ; enduntil;
        vedscr_read_ascii() ->;
        ved_q();
    endif;
enddefine;

define run_forced(net, seqno, detail);
    lvars p, first_pattern, last_pattern;
    vars stim, targ, output;

    if detail = "long" then 2 -> detail else 1 -> detail; endif;

    0.0 -> pdp3_mu(net);

    pdp3_seqstart(pats)(seqno) -> first_pattern;
    pdp3_seqend(pats)(seqno) -> last_pattern;

    [% fast_for p from first_pattern to last_pattern do
            pdp3_selectpattern(p,pats) -> (stim,targ);
            stim -> pdp3_response(net) -> output;
            output_operations(pdp3_largest(output))(detail);
        endfast_for; %];

enddefine;
