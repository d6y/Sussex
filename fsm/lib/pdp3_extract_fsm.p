/*
    PDP3_EXTRACT_FSM.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>
    Thursday 9 April 1992

    Updated: Monday 25 May 1992

    Given a PDP3 network and patter file, recovers the finite state
    machine that it implements.

    States are numbered (zero is reserved as the start state).
    See: HELP * PDP3    HELP * FSM


*/

uses fsm;
uses quantize_vector;

vars fsm_map_inputs;

define make_fsm(seq,states,Probs,name,netout,stimnames,endpoints) -> machine;
    vars npats=length(stimnames), i, nstates=length(states), ndifpats, inputs,
        in_name, in_pat_no, curr_state_no, next_state_no, tbl, curr_state,
        pre, terminals, terminal_state, nseq, seqend, s, first_pat, last_pat,
        outputs, non_deterministic=false;

    ;;; How many _________different input names?
    [] -> inputs;
    for i from 1 to npats do
        unless stimnames(i) isin inputs then
            stimnames(i) :: inputs -> inputs;
        endunless;
    endfor;
    length(inputs) -> ndifpats;

    newarray([0 ^nstates]) -> outputs;
    newarray([0 ^nstates 1 ^ndifpats]) -> tbl;

    1 -> first_pat;
    for s in endpoints do

        0 -> curr_state_no;     ;;; initial state is ZERO

        for i from first_pat to s do    ;;; for each input...
            ;;; find input pattern number
            stimnames(i) -> in_name;
            inputs --> [??pre ^in_name ==];
            length(pre) + 1 -> in_pat_no;
            seq(i) -> next_state_no;    ;;; next state

            if isnumber(tbl(curr_state_no,in_pat_no)) then
                unless tbl(curr_state_no,in_pat_no) = next_state_no then
                    ['WARNING!' Node ^curr_state_no is 'non-deterministic'] =>
                    true -> non_deterministic;
                endunless;
            endif;

            next_state_no -> tbl(curr_state_no,in_pat_no);
            netout(i) -> outputs(next_state_no);

            next_state_no -> curr_state_no;
        endfor;
        s+1 -> first_pat;
    endfor;

    ;;; Find terminal symbols
    [%  for s from 1 to nstates do
            true -> terminal_state;
            for i from 1 to ndifpats do
                if tbl(s,i) /= undef then
                    false -> terminal_state;
                endif;
            endfor;
            if terminal_state then s; endif;    ;;; on stack, into list
        endfor; %] -> terminals;

    consfsm_record(name,states,inputs,outputs,tbl,terminals,non_deterministic)
        -> machine;

    if isprocedure(fsm_map_inputs) then
        fsm_map_inputs(machine);
    endif;

enddefine;

define pdp3_extract_fsm(net,Probs,nStates,MaxSteps) -> machine;
    vars acts, p, states=[], same, counter, endpoints, numbers,
        nin = pdp3_nin(net), previous_state_no,
        nhid= pdp3_nunits(net)-nin-pdp3_nout(net), state_no,
        state, sequence_of_states, hidvec, statevec, netout, stim, targ
        actualout, ov, time, input_string, in_stim, first_time, stimnames;

    1 -> state_no;  ;;; zero is reserved for "initial state"

    0 -> counter;
    [] -> stimnames;
    [] -> endpoints;

    [% for numbers in Probs do
            0 -> time;
            true -> first_time;
            init_vars();

            set_problem(numbers) -> PAGE;

            repeat
                code_input(first_time, nhid) -> (input_string, in_stim);
                false -> first_time;

                in_stim -> pdp3_activate(net) -> ov;
                ov; ;;; on stack
                counter+1 -> counter;
                '' -> s;
                for i from 0 to nin-nhid-1 do
                    s >< (pdp3_activity(net)(i)) -> s;
                endfor;
                s :: stimnames -> stimnames;
                ov -> pdp3_output(net) -> ov;
                output_operations(pdp3_largest(ov))(2) -> op;
                if op = "mark_carry" then ;;; Needed surely?
                    tens();
                endif;
                popval([^op (); ])->;
                time + 1 -> time;

            quitif(time = MaxSteps or op = "done");

            endrepeat;

            counter :: endpoints -> endpoints;

        endfor; %] -> acts;

    rev(endpoints) -> endpoints;
    rev(stimnames) -> stimnames;

    ;;; build up table of all states and associated hidden activations
    ;;; (in -state-) and record sequence_of_states

    [% fast_for p from 1 to length(acts) do
            acts(p) -> pdp3_output(net) -> actualout;
            output_operations(pdp3_largest(actualout))(1);
        endfast_for; %] -> netout;

    [% fast_for p from 1 to length(acts) do

            acts(p) -> pdp3_hidden(net) -> hidvec;

            quantize_vector(hidvec,nStates) -> hidvec;

            (states matches [== [^hidvec ?previous_state_no] ==]) -> same;

            if same then
                previous_state_no;          ;;; state number on stack
            else ;;; New state
                state_no;                   ;;; drop on stack
                [^(copydata(hidvec)) ^state_no] :: states -> states;
                state_no + 1 -> state_no;   ;;; new state
            endif;

        endfast_for; %] -> sequence_of_states;

    make_fsm(sequence_of_states, states, Probs,
        pdp3_adddot(net,false),netout,stimnames,endpoints) -> machine;

enddefine;
