uses perform_action;

define make_problem_label(problem) -> phead;
    lvars op,p,rest=tl(tl(problem));
    problem(1) -> op;
    ''><problem(2) -> phead;
    for p in rest do
        phead >< op >< p -> phead;
    endfor;
enddefine;

vars xa_x0, xa_y0, xa_xs, xa_ys;

9 -> xa_xs;
10 -> xa_ys;
20 -> xa_y0;
20 -> xa_x0;

define xdigit(x,y,digit);
    rc_print_at(xa_x0 + x*xa_xs, xa_y0 + y*xa_ys, ''><digit);
enddefine;

define digitbox(x,y);
    rc_jumpto(xa_x0 + x*xa_xs - xa_xs/5.5, xa_y0 + y*xa_ys - xa_ys*1.4);
    rc_draw_rectangle(xa_xs*1.2,xa_ys*1.5);
enddefine;

define xshow(p);
    rc_start();
    vars i,j,d,nr,nc;
    length(p) -> nr;
    length(p(1)) -> nc;
    fast_for i from 1 to nr do
        if member("=",p(i)) then
            rc_jumpto(xa_x0*1.4 + nc*xa_xs, (i-0.75)*xa_ys + xa_y0);
            rc_drawto(xa_x0*1.4,(i-0.75)*xa_ys + xa_y0);
        endif;
    endfast_for;

    fast_for i from 1 to nr do
        fast_for j from 1 to nc do
            p(i)(j) -> d;
            if isnumber(d) then
                xdigit(j,i,d);
            endif;
        endfast_for;
    endfast_for;
enddefine;

define runnet(net,MaxTime,threshold) -> (Seq, reason);
    vars time, key, in_stim, input_string, ov,op, nhid, first_time;

    init_vars();
    0.0 -> pdp3_mu(net);
    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    1 -> time;
    true -> first_time;
    [%
        [% 'empty'; 'empty'; undef; copytree(PAGE); undef; undef; %];

        repeat

            code_input(first_time, nhid) -> (input_string, in_stim);
            false -> first_time;

            in_stim -> pdp3_response(net) -> ov;
            time + 1 -> time;

            pdp3_largest(ov) -> unit;

            output_operations(unit)(2) -> op;
            unless ov(unit) < threshold then
                [% input_string; perform_action(op);
                copydata(ov); copydata(PAGE);
                ROW; COLUMN; %];
            endunless;

            if op = "done" then
                'Finished' -> reason; quitloop;
            elseif time = MaxTime then
                'Time out' -> reason; quitloop;
            elseif ov(unit) < threshold then
                'Below threshold' -> reason; quitloop;
            endif;

        endrepeat;

    %] -> Seq;

enddefine;





define correct_run(answer_proc) -> Seq;
    vars first_time = true, ORIG_PAGE, input_string, in_stim, op;

    copytree(PAGE) -> ORIG_PAGE;
    [% answer_proc(); %] -> outputs;
    copytree(ORIG_PAGE) -> PAGE;

    [%
        [% 'empty'; 'empty'; undef; copytree(PAGE); undef; undef; %];

        for op in outputs do

            code_input(first_time, 1) -> (input_string, in_stim);
            false -> first_time;

            [% input_string; perform_action(op); {0}; copydata(PAGE);
                ROW; COLUMN; %];

        endfor;

    %] -> Seq;

enddefine;

vars hidden_endpoints;

define record_hidden(net,MaxTime,threshold, problems)
        -> (hidden_vecs,vec_names);

    vars time, in_stim, input_string, ov, op, nhid, first_time,
        problem, hv, unit, phead,p, nextinputs, total_time=0,
        pn, nprobs = length(problems), inorout;

    vis_sheet('Input or output') -> inorout;

    length(input_bits) -> nextinputs;

    [] -> hidden_vecs;
    [] -> vec_names;
    [] -> hidden_endpoints;

    0.0 -> pdp3_mu(net);
    pdp3_nunits(net) - pdp3_nout(net) - pdp3_nin(net) -> nhid;

    for pn from 1 to nprobs do

        if selection_sheet(pn) = true then

            problems(pn) -> problem;

            set_problem(problem) -> PAGE;
            init_vars();
            0 -> time;
            true -> first_time;

            make_problem_label(problem) -> phead;


            repeat
                code_input(first_time, nhid) -> (input_string, in_stim);
                false -> first_time;

                in_stim -> pdp3_activate(net) -> activity;
                activity -> pdp3_output(net) -> ov;
                activity -> pdp3_hidden(net) -> hv;

                pdp3_largest(ov) -> unit;
                output_operations(unit)(2) -> op;

                unless ov(unit) < threshold then

                    time + 1 -> time;
                    total_time + 1 -> total_time;

                    '' -> input_string;

                    if vis_sheet('Show problem') then
                        phead -> input_string;
                    endif;

                    if inorout = "input" or inorout = "both" then
                        for p from 1 to nextinputs do 48+in_stim(p); endfor;
                        consstring(nextinputs) -> in_stim;
                        unless input_string = '' then
                            input_string >< '-' -> input_string;
                        endunless;
                        input_string >< (decode_input(in_stim)) -> input_string;
                    endif;


/*
    shorten(op) -> gghh;
if gghh = "NAR" or gghh = "DON" then
    gghh ==>
    [% for hvi in hv using_subscriptor subscrv do
    hvi;
    endfor; %] ==>
endif;
*/

                    if inorout = "output" or inorout = "both" then
                        unless input_string = '' then
                            input_string >< '-' -> input_string;
                        endunless;

                        input_string  >< shorten(op) -> input_string;
/*
    if gghh = "DON" or gghh = "NAR" then
                        input_string  >< shorten(op) -> input_string;
    endif;
*/
                    endif;

                    if vis_sheet("Time") then
                        unless input_string = '' then
                            input_string >< '-' -> input_string;
                        endunless;
                        input_string><time -> input_string;
                    endif;

                    hv :: hidden_vecs -> hidden_vecs;
                    [%input_string;%] :: vec_names -> vec_names;
                    perform_action(op)->;
                endunless;

                if op = "done" then
                    'Finished' -> reason; quitloop;
                elseif time = MaxTime then
                    'Time out' -> reason; quitloop;
                elseif ov(unit) < threshold then
                    'Below threshold' -> reason; quitloop;
                endif;

            endrepeat;

            total_time :: hidden_endpoints -> hidden_endpoints;
            say(reason><' '><problem);

        endif;

    endfor;

    rev(hidden_vecs) -> hidden_vecs;
    rev(vec_names) -> vec_names;
    rev(hidden_endpoints) -> hidden_endpoints;
enddefine;


vars Xcol, Xrow, xrunnet_ov;

define xdraw(list,p);
    vars ins,ot,page,largest_count;
    lvars largest, err, i, ncols, next_largest, nl_op, counter;

    list(p) --> [?ins ?ot ?xrunnet_ov ?page ?Xrow ?Xcol];

    length(page(1)) -> ncols;
    ''><ins -> net_sheet('Input');
    ''><ot -> net_sheet('Output');

    xshow(page);
    (p-1) >< ' of '><solution_time -> net_sheet("Step");

    if isnumber(Xcol) and isnumber(Xrow) then
        digitbox((ncols-Xcol)+1,Xrow);
    endif;

    if net_sheet('Show error') and xrunnet_ov /= undef then
        1 -> counter;
        0.0 ->> err ->> largest -> next_largest;
        fast_for i in xrunnet_ov using_subscriptor subscrv do
            if i > largest then
                largest -> next_largest;
                largest_count -> nl_op;
                i -> largest;
                counter -> largest_count;
            elseif i > next_largest then
                counter -> nl_op;
                i -> next_largest;
            endif;
            err + i -> err;
            counter + 1 -> counter;
        endfast_for;
        err - largest + (1-largest) -> err;
        ''><err -> net_sheet("Error");
        output_operations(nl_op)(1) -> nl_op;
        ''><nl_op><'-'><(largest-next_largest) -> net_sheet("Closest");
    endif;


enddefine;


define spew_sequence;
    vars ins,ot,largest_count;
    lvars largest, err, i, ncols, count=1, op_count, next_largest, nl_op;
    (sys_fname_nam(pdp3_wtsfile(net)))><'_'><
    (make_problem_label(current_problem))><'.txt' -> spew_file;
    fopen(spew_file,"w")->dev;

    fputstring(dev,'t   op  eye  err   closest     input');
    fputstring(dev,'----------------------------------------------------------');
    foreach [?ins ?ot ?xrunnet_ov ?page ?Xrow ?Xcol] in Solution do

        unless ins = 'empty' then

            finsertstring_left(dev,count><' ',4);
            finsertstring(dev,shorten(ot)><' ');
            finsertstring(dev,'r'><Xrow><'c'><Xcol><' ');

            if net_sheet('Show error') then

                0.0 ->> err ->> largest -> next_largest;
                1 ->> op_count -> largest_count;
                fast_for i in xrunnet_ov using_subscriptor subscrv do
                    if i > largest then
                        largest -> next_largest;
                        largest_count -> nl_op;
                        i -> largest;
                        op_count -> largest_count;
                    elseif i > next_largest then
                        i -> next_largest;
                        op_count -> nl_op;
                    endif;
                    err + i -> err;
                    op_count + 1 -> op_count;
                endfast_for;
                err - largest + (1-largest) -> err;
                output_operations(nl_op)(1) -> nl_op;

                finsertstring_left(dev,err><' ',5);
                finsertstring(dev,' '><nl_op><' ');
                finsertstring_left(dev,(largest-next_largest)><'',6);
            endif;

            finsertstring(dev,'  '><ins);

            fnewline(dev); count+1 -> count;
        endunless;
    endforeach;

    fclose(dev);
    say('Text written to '><spew_file);
enddefine;

vars xrunnet_procs = true;
