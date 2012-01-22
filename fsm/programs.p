
15000000 -> popmemlim;

extend_searchlist('~richardd/fsm/lib',popliblist) -> popliblist;
extend_searchlist('~richardd/fsm/lib',popuseslist) -> popuseslist;
extend_searchlist('~richardd/fsm/progs',popliblist) -> popliblist;
extend_searchlist('~richardd/fsm/progs',popuseslist) -> popuseslist;

load ~/pop/pdp3/pdp3.p
uses maths_routines;
uses operations;
uses code_input;
;;;uses look_util.p
uses symmap;
uses perform_action;

load progs/run_net.p
load progs/io_mapping.p
;;; io_mapping([x 2 3],'~/x23.txt');


/*-------- Graphics only ---------*/

/*
uses rcg
uses pdp3_extract_fsm.p
uses rc_draw_fsm.p


find_states(net,[ [+ 1 1] [+ 1 1 1] ],30,true) -> m;
print_fsm(m);
*/




/*

uses xrunnet;

vars count = 0;

define insert_digit;
    if random(1.0) < 0.046 then
        if count == 7 then
            0;
        else
            1;
            count + 1 -> count;
        endif;
    else
        0;
    endif;
enddefine;

define x_run_a_problem(Problem);
vars Seq, Reason;
    set_problem(Problem) -> PAGE;
    runnet(net,99999999999999999999999999999,0.0) -> (Seq,Reason);
;;;    xshow(last(Seq)(4));
[^accumulator ^(count+1)]=>
enddefine;

x_run_a_problem([% "+"; repeat 100 times insert_digit(); endrepeat; 1; %]);

x_run_a_problem([+ 4 1 1 1 1 1]);
*/
