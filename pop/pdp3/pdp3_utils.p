/*
    PDP3_UTILS.P

    Author:  Richard Dallaway, September 1991
    Purpose: Utilities for the PDP3 set of programs
    Version: Thursday 16 July 1992
*/

defclass procedure pdp3_net_record {
    pdp3_wtsfile,       ;;; string
    pdp3_nunits,        ;;; int, number of units
    pdp3_nin,           ;;; int, number of inputs
    pdp3_nout,          ;;; int, number of outputs
    pdp3_weights,       ;;; array(from,to)
    pdp3_connectivity,  ;;; vector
    pdp3_senders,       ;;; array(nunits), vectors indicating connections
    pdp3_netinput,      ;;; array(nunits)
    pdp3_activity,      ;;; array(nunits),
    pdp3_mu,            ;;; float
    pdp3_tmax,          ;;; float
    pdp3_style,         ;;; word
    pdp3_biases         ;;; array(nunits)
};

defclass procedure pdp3_pats_record {
    pdp3_patsfile,      ;;; string
    pdp3_stims,         ;;; array
    pdp3_targs,         ;;; array
    pdp3_stimnames,     ;;; array
    pdp3_seqstart,      ;;; vector
    pdp3_npats,         ;;; int
    pdp3_inlines,       ;;; int
    pdp3_outlines       ;;; int
};

/* Used by pdp3_getweights and pdp3_getpatterns to ensure that
   the user has not missed data from a name.  Returns <false> if
   all data from DEVICE has been read, or a string containing
   the next twenty characters.
*/

define check_for_remains(device) -> line;
    vars p,line,i;
    getc(device) -> p;
    unless p = termin then  ;;; more data
        inits(20) -> line;
        p -> line(1);
        for i from 2 to 20 do   ;;; what's it look like?
            getc(device) -> p;   ;;; read next 20 characters to
            if p = termin then  ;;; show to the user.
                46 -> line(i);  ;;; dots at the end
            elseif p < 32 then
                47 -> line(i);  ;;; slashes for control codes (e.g., newline)
                else
                p -> line(i);
            endif;
        endfor;
    else    ;;; all data read
        false -> line;
    endunless;
enddefine;


/* Logistic activation function taken from M&R code bp.c */

define logistic(x);
    if x > 15.935773 then
        0.99999988;
    elseif x < -15.935773 then
        0.00000012;
    else
        1.0/(1.0+exp(-x));
    endif;
enddefine;

/* add name name extension if needed */

define pdp3_adddot(name, ext) -> name;

    if isstring(name) and ext /= false then ;;; real file name
        if issubstring('.',name) = false then
            name >< '.' >< ext -> name; ;;; add extension if none given
        endif;
    else

        if ispdp3_net_record(name) then ;;; weights file
            name.pdp3_wtsfile -> name;
        elseif ispdp3_pats_record(name) then ;;; pattern file
            name.pdp3_patsfile -> name;
        else ;;; what could it be?
            mishap('PDP3_ADDDOT: Could not add \''><ext><'\' extension',[^name]);
        endif;

        if ext /= false then
            issubstring('.', name) -> p;
            if p = false then
                name >< '.' >< ext -> name;
            else
                substring(1,p,name) >< ext -> name;
            endif;
        else
            issubstring('.', name) -> p;
            unless p = false then
                substring(1,p-1,name)  -> name;
            endunless;
        endif;
    endif;
enddefine;


define pdp3_copynet(net) -> newnet;
    copydata(net) -> newnet;
    gen_suffixed_word("net_") -> pdp3_wtsfile(newnet);
enddefine;



/***************  G L O B A L   V A R I A B L E S  *********************/

vars First_unit, First_input_unit, Last_input_unit, First_hidden_unit,
    Last_hidden_unit, First_output_unit, Last_output_unit, Last_unit;

vars Number_of_patterns, First_pattern, Last_pattern;

vars pdp3_dont_auto_setpoints = false;

vars pdp3_printweights_d1 = 3;
vars pdp3_printweights_d2 = 3;
vars pdp3_printweights_rowspace = 2;

vars pdp3_printpats_d0 = 5;
vars pdp3_printpats_d1 = 3;
vars pdp3_printpats_d2 = 3;
vars pdp3_printpats_numbers = true;

vars pdp3_printpats_inputstr = 'Inputs';
vars pdp3_printpats_targetstr = 'Targets';

vars pdp3_recurrent_cascade = false;

vars pdp3_maximum_pattern_size = 20000;

vars pdp3_initialcontext = 0.0;

vars pdp3_utils = true;
