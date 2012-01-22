/*
    FSM.P

    Richard Dallaway <richardd@cogs.susx.ac.uk>

    Code for (deterministic) finite state machines.

    See HELP * PDP3
        HELP * FSM
        pdp3_extract_fsm.p
        rc_draw_fsm.p

    Monday 13 April 1992

         CONTENTS - (Use <ENTER> g to access required sections)

 -- fsm_record class
 -- print_fsm(machine)
 -- fsm_file(filename) -> Machine
 -- machine -> fsm_file(filename);
 -- fsm_minimize(M) -> M'
 -- run_fsm(M, inputs) -> (state_sequence, EOI, validity);

*/

uses sysio;
uses vstack_hlist;

define macro DEBUG;
    "if", "Debugging", "then";
enddefine;

define macro GUBED;
    "endif";
enddefine;

vars Talkative = true;
vars Debugging = false;

/*
-- fsm_record class ---------------------------------------------------
*/

defclass procedure fsm_record {
    fsm_name,       ;;; string
    fsm_states,     ;;; list of state names
    fsm_inputs,     ;;; list of input names
    fsm_outputs,    ;;; lables for each state
    fsm_table,      ;;; array[states,inputs]
    fsm_terminals,  ;;; list of terminals symbols in fsm_inputs
    fsm_extraction_method,  ;;; Word
    fsm_extraction_value,   ;;; Number
    fsm_non_deterministic   ;;; true or false
};

define fsm_nonterminals(M) /* -> nonterminals */ ;
    vars i, nstates = length(fsm_states(M));
    [% for i from 0 to nstates do
            unless i isin fsm_terminals(M) then
                i;
            endunless;
        endfor; %];
enddefine;

/*
-- print_fsm(machine) -------------------------------------------------
*/

vars fsm_widest_input_name;
unless isnumber(fsm_widest_input_name) then
    1 -> fsm_widest_input_name;
endunless;

vars pdp3_fsm_out_prwidth;
unless isnumber(pdp3_fsm_out_prwidth) then
    12 -> pdp3_fsm_out_prwidth;
endunless;

define print_fsm(M);
    vars width, i, s, nstates, ninputs;
    pr('Transition table for: '><fsm_name(M)); nl(1);
    length(fsm_states(M)) -> nstates;
    length(fsm_inputs(M)) -> ninputs;
    1+log10(nstates) -> width;
    unless intof(width) = width then intof(width)+1 -> width; endunless;
    max(4,width) -> width;
    vstack_hlist(width+2, [% for i from 1 to ninputs do fsm_inputs(M)(i); endfor; %], width);
    for s from 0 to nstates do
        pr_field(s,width,' ',false);
        if s isin fsm_terminals(M) then pr('| '); else pr(': '); endif;
        for i from 1 to ninputs do
        if fsm_table(M)(s,i) = undef then
            pr_field('-',width,' ',' ');
        else
            pr_field(fsm_table(M)(s,i),width,' ',' ');
        endif;
        endfor;
        pr_field(fsm_outputs(M)(s), pdp3_fsm_out_prwidth, false,' ');  nl(1);
    endfor;

if fsm_non_deterministic(M) = true then
    pr('Data lost because of non-deterministic node(s)'); nl(1);
endif;

enddefine;

/*
-- fsm_file(filename) -> Machine --------------------------------------

    Reads an ascii file called "filename.fsm" of the form:
        inputs: a b c d          Inputs can be any symbols
        A       B - - C  labA    States are converted for numbers.
        B       - - D -  labB    The first state is expected to be the
        etc                      start state. States can have word labels

*/

define fsm_file(filename) -> M;
    vars dev, line, raw_table, state_names, terminal_symbol, terminals, states,
        next_state, pre, group, nstates, ninputs, inputs, tbl, state_labels;

    unless issubstring('.',filename) then
        filename >< '.fsm' -> filename;
    endunless;

    fopen(filename,"r") -> dev;
    if dev = false then
        mishap('READ_FSM: Can\'t open file',[^filename]);
    endif;

    fstringsize(dev,1000);

    stringtolist(fgetstring(dev)) -> line;
    unless hd(line) = "inputs" then
        mishap('READ_FSM: Missing \"inputs:\" line',[^filename ^line]);
    endunless;
    tl(tl(line)) -> inputs;

    [% repeat
            fgetstring(dev) -> line;
        quitif(line = termin);
            stringtolist(line);
        endrepeat; %] -> raw_table;

    fclose(dev);

    length(raw_table)-1 -> nstates;
    length(inputs) -> ninputs;

    newarray([0 ^nstates 1 ^ninputs]) -> tbl;

    [% for s from 0 to nstates do
            raw_table(s+1)(1);
        endfor; %] -> state_names;

    newarray([0 ^nstates]) -> state_labels;

    for s from 0 to nstates do
            raw_table(s+1) -> line;
            if length(line) > ninputs+1 then
                line(ninputs+2) -> state_labels(s);
            else
                "?" -> state_labels(s);
            endif;
        endfor;

    [] -> terminals;
    for s from 0 to nstates do
        true -> terminal_symbol;
        for i from 1 to ninputs do
            raw_table(s+1)(1+i) -> next_state;
            unless next_state = "-" then
                false -> terminal_symbol;
                if state_names matches [??pre ^next_state ==] then
                    length(pre) -> tbl(s,i);
                else
                    mishap('READ_FSM: Undefined state',
                        [state ^next_state from state ^(state_names(s+1))]);
                endif;
            endunless;
        endfor;
        if terminal_symbol then s :: terminals -> terminals; endif;
    endfor;

    consfsm_record(filename,[% for i from 1 to nstates do i; endfor; %],
        inputs,state_labels,tbl,"file",false,terminals) -> M;

enddefine;

/*
-- machine -> fsm_file(filename); --------------------------------------------
*/

define updaterof fsm_file(M);
    vars width, i, s, nstates, ninputs,dev;

    if isstring(M) then
        M -> filename;
            -> M;
    else
        fsm_name(M) -> filename;
    endif;

    unless issubstring('.',filename) then
        filename >< '.fsm' -> filename;
    endunless;

    fopen(filename,"w") -> dev;

    finsertstring(dev,'inputs: ');
    length(fsm_states(M)) -> nstates;
    length(fsm_inputs(M)) -> ninputs;
    1+log10(nstates) -> width;
    unless intof(width) = width then width+1 -> width; endunless;
    intof(width) -> width;
    for i from 1 to ninputs do
        finsertstring_left(dev,fsm_inputs(M)(i),width);
    endfor;
    finsertstring(dev,'\n');
    for s from 0 to nstates do
        finsertstring(dev,s><'\t\t');
        for i from 1 to ninputs do
            if fsm_table(M)(s,i) = undef then
                finsertstring_left(dev,'-',width);
            else
                finsertstring_left(dev,fsm_table(M)(s,i),width);
            endif;
        endfor;
    finsertstring(dev,'   '><fsm_outputs(M)(s));
    finsertstring(dev,'\n');
    endfor;
    fclose(dev);
enddefine;

/*
-- fsm_minimize(M) -> M' ----------------------------------------------
    Minimizes a FSM based on the algorithm in Des' book.
*/


define fsm_minimize(M) -> m;
    vars partitions=[], ninputs, nstates, i, s, new_partitions,
        subgroup, new_subgroup, next_state, table old_state_nos,
        new_nstates, new_table, pre, post, old_state, old_next_state,
        new_terminals, non_terminals, state_labels;


    fsm_table(M) -> table;
    length(fsm_states(M)) -> nstates;
    length(fsm_inputs(M)) -> ninputs;

    ;;; Initial partitions of terminal and no-terminal states

    if fsm_terminals(M) /= [] then
        copytree(fsm_terminals(M)) :: partitions -> partitions;
    else
        mishap('FSM_MINIMIZE: Cannot minimize without a terminal state',
            [^M]);
    endif;


    fsm_nonterminals(M) -> non_terminals;

    if non_terminals = [] then
        mishap('FSM_MINIMIZE: All states are terminals',[^M]);
    else
        non_terminals :: partitions -> partitions;
    endif;

    repeat  ;;; partition until no changes

        DEBUG nl(2);
        [Start of cycle, partitions are:] =>
        partitions ==>
        GUBED;


        [] -> new_partitions;

        ;;; look at each partition in partitions list
        for group in partitions do

            if length(group) == 1 then  ;;; can't partition this one
                group :: new_partitions -> new_partitions;
                else
                ;;; Try to build a new subgroup
                [] -> subgroup;
                for s in group do
                    true -> new_subgroup;
                    for i from 1 to ninputs do
                        table(s,i) -> next_state;
                        ;;; is the state transition into the same group?
                        if not(member(next_state,group))
                        and next_state /= undef then
                            ;;; this state (s) is not part of the new subgroup
                            false -> new_subgroup;
                            quitloop;
                        endif;
                    endfor;

                    ;;; If state produces new states that are within the
                    ;;; same group on ___all inputs then it is part of the
                    ;;; new subgroup.
                    if new_subgroup then
                        s :: subgroup -> subgroup;
                    endif;
                endfor;

                unless subgroup = [] then
                    ;;; add the new subgroup to the partitions list
                    ;;; Reverse the list to make later comparision easy
                    rev(subgroup) :: new_partitions -> new_partitions;

                    ;;; remove subgroup from original group
                    [% for s in group do
                            unless s isin subgroup then s; endunless;
                        endfor; %] -> group;
                endunless;

                unless group = [] then
                    group :: new_partitions -> new_partitions;
                endunless;
            endif;
        endfor;

    if Talkative then
        pr('No. of partitions: '><length(new_partitions)); nl(1);
    endif;

    quitif(rev(new_partitions)=partitions);

        copytree(new_partitions) -> partitions;
    endrepeat;


    ;;; _____BUILD ___NEW _____TABLE

    length(partitions)-1 -> new_nstates;

    if new_nstates = nstates then   ;;; NO SAVING!
        M -> m; ;;; return save machine

        if Talkative then
            pr('Minimization complete.  No saving.\n');
        endif;

        else

        if Talkative then
            pr('Machine minimized. Saving of '><(nstates-new_nstates)><
                    ' states.\n');
        endif;

        newarray([0 ^new_nstates 1 ^ninputs]) -> new_table;

        ;;; ensure zero state is at the start of the list
        ;;; so that it is zero in the new table
        partitions --> [==[??pre 0 ??post]==];
        delete([^^pre 0 ^^post],partitions) -> partitions;
        [0 ^^pre ^^post] :: partitions -> partitions;

        ;;; order of groups in this list is used as the
        ;;; state number for the new table.
        [% for s from 0 to new_nstates do
                partitions(s+1);
            endfor; %] -> old_state_nos;

        ;;; renumber states

        newarray([0 ^nstates]) -> state_labels;

        for s from 0 to new_nstates do
            ;;; select just the first state in a group
            partitions(s+1)(1) -> old_state;
            ;;; copy the state's label
            ;;; Assumption: all the reduced states should have
            ;;; the same label (because they do exactly the same thing)
            ;;; so it doesn't matter which one of the partitions'
            ;;; labels we use.
            fsm_outputs(M)(old_state) -> state_labels(s);
            ;;; copy into the new transition table
            for i from 1 to ninputs do
                table(old_state,i) -> old_next_state;
                unless old_next_state = undef then
                    ;;; the position of the old_state number in the
                    ;;; list is the new state number.
                    old_state_nos --> [??pre [== ^old_next_state==] ==];
                    length(pre) -> new_table(s,i);
                endunless;
            endfor;
        endfor;

        ;;; Copy across any terminal symbols
        [] -> new_terminals;
        for s in fsm_terminals(M) do
            old_state_nos --> [??pre [== ^s ==] ==];
            ;;; don't include a state more than once
            unless length(pre) isin new_terminals then;
                length(pre) :: new_terminals -> new_terminals;
            endunless;
        endfor;

        consfsm_record( addprefix(fsm_name(M), 'min_'),
            [% for i from 1 to new_nstates do i; endfor; %],
            copytree(fsm_inputs(M)), state_labels, new_table,
                new_terminals, fsm_extraction_method(M),
                fsm_extraction_value(M),
                fsm_non_deterministic(M) ) -> m;
    endif;

enddefine;

/*
-- run_fsm(M, inputs) -> (state_sequence, EOI, validity); -------------
   EOI is <true> if the input_steam was exhausted, and <false> if a
   terminal state was reached. A string is valid (validity = true) if
   all input symbols have been consumed and the final sate is a terminal
   state.
*/

define run_fsm(M,input_stream) -> (state_sequence, EOI, validity);
    vars table, inputs, terminals, state, next_state, char, input_no, pre;

    fsm_table(M) -> table;
    fsm_terminals(M) -> terminals;
    fsm_inputs(M) -> inputs;
    [] -> state_sequence;
    false -> EOI;
    false -> validity;
    0 -> state;

    until (input_stream = []->>EOI) or state isin terminals do

        dest(input_stream) -> input_stream -> char;
        if inputs matches [??pre ^char ==] then
            length(pre) + 1 -> input_no;
        else
            mishap('RUN_FSM: Illegal input symbol',
                [^char read in state ^state]);
        endif;

        table(state,input_no) -> next_state;
        if next_state = undef then
            mishap('RUN_FSM: Undefined transition',
                [from state ^state on input ^char]);
        endif;

        next_state -> state;
        state_sequence <> [% state; %] -> state_sequence;
    enduntil;

    if EOI=true and state isin terminals  then
        true -> validity;
    endif;

enddefine;

vars fsm = true;
