uses sorting;
uses quantize_vector;

/*
         CONTENTS - (Use <ENTER> g to access required sections)

 -- Build up a list of [HiddenVector StateNumber InputString Output]
 -- Remove similar states
 -- Build FSM transition table

find_states(    pdp3 network,
                problem list,
                time out,
                activity threshold,
                simple label flag,
                method
            ) -> finite state machine;

Method may be
        "Maskara"
    or  "Quantize"

The value of fsm_similarity_threshold is used either as a real similarity
threshold (e.g., 0.05) OR as the number of states to quantize to (e.g., 3).

*/


vars fsm_similarity_threshold = 0.05;

define ave_vec(v1,v2);
    lvars i,vl=length(v1);
    {% fast_for i from 1 to vl do
            (v1(i)+v2(i))/2.0;
    endfast_for %};
enddefine;

define aresimilar(v1,v2) -> result;
    lvars i,vl=length(v1);
    true -> result;
    fast_for i from 1 to vl do
        if abs(v1(i)-v2(i)) > fsm_similarity_threshold then
            false -> result;
            quitloop;
        endif;
    endfast_for;
enddefine;

define euclid(v1,v2);
    lvars i,t=0,vl=length(v1);
    fast_for i from 1 to vl do
        (v1(i)-v2(i))**2 + t -> t;
    endfast_for;
    sqrt(t);
enddefine;

define sort_by_euclid(h,c,cv);
    vars i,v;
    [% for i in c do
            h(i)(1) -> v;
            [% euclid(v,cv); i;%];
        endfor; %] -> c;

    sort_by_n_num(c,1) -> c;

    [% foreach [= ?i] in c do i; endforeach; %];
enddefine;



define find_states(net,problems,time_out,threshold,simple_labels,method)
        -> machine;
    vars
        problem, first_time, time, nhid, input_string, input_stimulus,
        output_vector, hidden_vector, activity, state_number, winner,
        op,p, nexternalinputs = length(input_bits), in_stim;

    (pdp3_nunits(net)-pdp3_nin(net))-pdp3_nout(net) -> nhid;
    1 -> state_number;


    if not(member(method,[Quantize Maskara])) then
        mishap('FIND_STATES:  Unknown state maching method',[^method]);
    endif;


/*
-- Build up a list of [HiddenVector StateNumber InputString Output] ---
*/

    vars history = [%

            for problem in problems do

            [START];
        0 -> time;
        true -> first_time;
        init_vars();
        set_problem(problem) -> PAGE;
        repeat
            code_input(first_time,nhid) -> (input_string, input_stimulus);
            false -> first_time;
            input_stimulus -> pdp3_activate(net) -> activity;

            activity -> pdp3_output(net) -> output_vector;
            pdp3_largest(output_vector) -> winner;

            perform_action(output_operations(winner)(2)) -> op;

            [%

                if method = "Quantize" then
                    quantize_vector(activity -> pdp3_hidden(net),
                        fsm_similarity_threshold);
                else ;;; Maskara
                    (activity -> pdp3_hidden(net));
                endif;

                state_number;
                state_number + 1 -> state_number;
                input_string;
                op;
            %];

            if output_vector(winner) < threshold then
                [END THRESHOLD];
                quitloop;
            else
                if op = "done" then
                    [END];
                    quitloop;
                endif;
            endif;

            time + 1 -> time;
            if time = time_out then
                [END TIMEOUT];
                quitloop;
            endif;

        endrepeat;

    endfor; %];



/*
-- Remove similar states ----------------------------------------------
    */

    vars nstates, i,j, i_state, j_state, change, i_vec, v, i_op;

    length(history) -> nstates;

    for i from 1 to nstates-1 do

        unless member(history(i)(1),[START END]) then

            history(i)(2) -> i_state;       ;;; State number
            history(i)(1) -> i_vec;         ;;; Vector
            history(i)(4) -> i_op;          ;;; output operation
            [] -> change;

            for j from i+1 to nstates do

                unless member(history(j)(1),[START END]) then

                    if method = "Quantize" then
                        if history(j)(1) = i_vec then
                            i_state -> history(j)(2);
                        endif;
                    else
                        ;;; check that they are different first
                        if history(j)(2) /= i_state then
                            ;;; Now check for similarity
                            if aresimilar(history(j)(1),i_vec) then
                                j :: change -> change;
                            endif;
                        endif;
                    endif;

                endunless;

            endfor;

            ;;; change will be empty when using Quantize method

            unless change = [] then
                sort_by_euclid(history,change,i_vec) ->change;
                i_vec -> v;
                for j in change do
                    i_state -> history(j)(2);
                    ave_vec(history(j)(1),v) -> v;
                endfor;
                v -> history(i)(1);
                for j in change do
                    v -> history(j)(1);
                    if history(j)(4) /= i_op then
                        pr('Odd: States to be merged have different operations associated with them'); nl(1);
                        pr('States are: '><i_op><' and '><(history(j)(4))); nl(1);
                        pr('Assuming it should be '><i_op); nl(2);
                        i_op -> history(j)(4);
                    endif;
                endfor;
            endunless;
        endunless;

    endfor;

/*
-- Build FSM transition table -----------------------------------------
    */


    ;;; how many DIFFERENT input vectors?

    vars input_stimuli = [];
    vars states = [];
    vars statenum, ndifinputs, nstates, table, outputs, line,
        from_state, pre, entry, input_number, nondeterministic=false,
        isterminal, ii, hv1, hv2, vl;

    foreach [= ?statenum ?input_stimulus =] in history do
        unless input_stimulus isin input_stimuli then
            input_stimulus :: input_stimuli -> input_stimuli;
        endunless;
        unless statenum isin states then
            statenum :: states -> states;
        endunless;
    endforeach;

    length(input_stimuli) -> ndifinputs;
    length(states) -> nstates;


    newarray([0 ^nstates 1 ^ndifinputs])-> table;
    newarray([0 ^nstates]) -> outputs;

    for line in history do

        if line = [START] then
            0 -> from_state;

        elseif hd(line) = "END" then
            ;;;

        else

            line --> [= ?statenum ?input_stimulus ?op];
            states --> [??pre ^statenum ==];
            length(pre)+1 -> state_number;
            input_stimuli --> [??pre ^input_stimulus ==];
            length(pre)+1 -> input_number;

            table(from_state,input_number) -> entry;

            if entry /= undef and entry /= state_number then
/*
We know that these machines CANNOT be nodeterministic, but
when two hidden vectors serve the same purpose, but are not
                classified as similar, then it'll look as if we have a nondeterministic
machine.  This doesn't matter much...it just measn the network is producing
spurious states (which with further training, should vanish).
*/
                nl(2);
                history --> [== [?hv2 ^statenum ==]==];
                length(hv2) -> vl;
                hv1 =>
                hv2=>
                sort([% for ii from 1 to vl do abs(hv2(ii)-hv1(ii)); endfor; %])=>
                pr('WARNING!  Non-deterministic finite state machine.'); nl(1);
                true -> nondeterministic;

            else
                history --> [== [?hv1 ^statenum ==]==];
            endif;

            state_number ->> table(from_state,input_number) -> from_state;
            op -> outputs(state_number);

        endif;
    endfor;

    ;;; Find terminal states

    vars i, isterminal;

    vars terminals = [%
            for i from 1 to nstates do
            true -> isterminal;
        for j from 1 to ndifinputs do
            if table(i,j) /= undef then
                false -> isterminal; quitloop;
            endif;
        endfor;
        if isterminal then i; endif;
    endfor; %];


    ;;; Build machine

    if simple_labels then
        for i from 1 to ndifinputs do
            ' ' -> input_stimuli(i);
        endfor;
    endif;

    vars name;

    pdp3_adddot(pdp3_wtsfile(net),'fsm') -> name;

    consfsm_record(name,states,input_stimuli,outputs,table,
        terminals,method,fsm_similarity_threshold,
        nondeterministic)
        -> machine;


enddefine;
