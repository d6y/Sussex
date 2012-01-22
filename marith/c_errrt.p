
vectorclass  float  decimal;
vars newfarray = newanyarray(%float_key%);

external_load('Error and RT recording in C',
    [%'/csuna/home/richardd/marith/errrt.o',''%],
    [ {type procedure} [_errrt c_errrt] ] );

define farr(a);
    vars b = boundslist(a), bl = length(b), x, y;
    if bl = 2 then
        newfarray(b,procedure(x); a(x); endprocedure);
    else
        newfarray(b,procedure(x,y); a(x,y); endprocedure);
    endif;
enddefine;


define errrt_setseed(seed);
    vars result, dummy_vector = arrayvector(newfarray([1 1],0));
    c_errrt(dummy_vector, dummy_vector, dummy_vector, 1, 1, 1,
        dummy_vector, dummy_vector, 1, 1, 1, 0.1, 0.1, intof(seed),
        1, dummy_vector, dummy_vector, dummy_vector,
        18, true) -> result;
enddefine;


errrt_setseed(random(32700));

define errrt(net, pats, first_pattern, last_pattern, time_limit,
        crate, min_threshold, max_threshold, nblocks )
            -> (errors,rts,result);

    vars poparray_by_row = false;   ;;; for C routines
    vars last_unit = (net.pdp3_nunits)-1, result, s, fsenders;
    vars npats = pats.pdp3_npats, omissions;
    lvars i,j,o;

    newfarray([0 ^npats]) -> rts;
    newfarray([0 ^npats 1 ^N_products],0) -> errors;
    newfarray([0 ^last_unit 0 ^last_unit],-1) -> fsenders;
    newfarray([0 ^(npats*nblocks)],-1) -> omissions;

    fast_for i from 0 to last_unit do
        (net.pdp3_senders)(i) -> s;
        for j from 1 to length(s) do
            s(j) -> fsenders(i,j);
        endfor;
    endfast_for;

    c_errrt(
        arrayvector(farr(net.pdp3_weights)),
        arrayvector(farr(net.pdp3_biases)),
        arrayvector(fsenders),
        intof(net.pdp3_nunits), /* coerce to int */
        intof(net.pdp3_nin),
        intof(net.pdp3_nout),

        arrayvector(farr(pats.pdp3_stims)),
        arrayvector(farr(pats.pdp3_targs)),
        intof(first_pattern-1),
        intof(last_pattern-1),

        intof(time_limit),
        1.0*crate,              /* coerce to float */
        1.0*min_threshold,
        1.0*max_threshold,
        intof(-1),
        intof(nblocks),

        arrayvector(errors),
        arrayvector(rts),
        arrayvector(omissions),
        19, true) -> result;

    if result = -1 then
        mishap('ERRRT: Memory could not be allocated in C',[]);
    endif;

    ;;; Convert to form acceptable to -count_errors-
    ;;; NB: we don't care about omission errors here

    newarray([2 ^N_problems 1 ^N_products], procedure(x,y);
            if y = 1 then 0; else intof(errors(x-1,y-1)); endif;
        endprocedure) -> errors;

    ;;; Convert RT to a form acceptable to intuition
    [% fast_for i from first_pattern-1 to last_pattern-1 do
            intof(rts(i)); endfast_for; %] -> rts;

    if result /= 0 then
        nl(2);
        pr('   ------------- WARNING ----------------\n');
        pr(result><' correct product(s) did not exceed the \n');
        pr('threshold within '); pr(time_limit><' steps.\n\n');

        ;;; Place omissions into ERRORS array

        fast_for o from 1 to result do
            1 + intof(errors(intof(omissions(o-1)+1),1))
                -> errors(intof(omissions(o-1)+1),1);
        endfast_for;

    endif;

enddefine;
