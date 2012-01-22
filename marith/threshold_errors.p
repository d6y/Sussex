load product_ZERO.p
uses sysio;

define pr_matrix(matrix);

    vars first_out, last_out, first_pat, last_pat;
    vars w=3, pw=5, a, b;

    boundslist(matrix) --> [?first_pat ?last_pat ?first_out ?last_out];

    pr_field('',pw,false,' ');
    for o from first_out to last_out do
        pr_field(product_list(o),w,' ',' ');
    endfor; nl(1);


    define show_errors(x,y);
        vars p = 2+((x-First_multiplier)*N_tables)+(y-First_multiplier);
        pr_field('p'><x><'x'><y,pw,false,' ');
        for o from first_out to last_out do
            prnum(matrix(p,o),w,0);
        endfor; nl(1);
    enddefine;

    for a from First_multiplier to Last_multiplier do
        for b from a to Last_multiplier do
            show_errors(a,b);
            unless a == b then
                show_errors(b,a);
            endunless;
        endfor;
    endfor;

enddefine;



/* An erroneous response, e, to the problem x times y is
   an Operand distance effect if e is a member of the set of
   products in the "cross" of products centred around x times y */

define cross(x,y,e,c); /* -> true or false */
    lvars a;
    member(e, [%
        fast_for a from max(First_multiplier,x-c) to min(Last_multiplier,x+c) do
            a*y;
        endfast_for;
        fast_for a from max(First_multiplier,y-c) to min(Last_multiplier,y+c) do
            x*a;
        endfast_for; %]);
enddefine;

define sametable(a,b,e);
vars x;
member(e,[% fast_for x from First_multiplier to Last_multiplier do
                a*x; x*b; endfast_for; %]);
enddefine;

;;; Is the table-unrealted error, e, the product next to (c=1)
;;; the correct product?
define tu_but_close(a,b,c,e) -> result;
    vars v,p,pre;
    false -> result;

    product_list --> [??pre ^(a*b) ==];
    1+length(pre) -> p;

    for v from max(p-c,2) to min(p+c,N_products) do
        ;;;[^v ^(product_list(v)) ^e]=>
        if product_list(v) = e then true -> result; endif;
    endfor;

enddefine;

vars problem_error_count;

define count_errors(matrix,count_types,nblocks);
    vars x,y,o,p,errors, error_count, ode, oe, tu, plus, error, tu_close, occur,
        near_a,near_b,two_prob, omitted, zero_xn, tie, tie_list, JUST_RETURN = false;

if nblocks = true then
    true -> JUST_RETURN;
    count_types -> nblocks;
    matrix -> count_types;
    -> matrix;
endif;

    0 ->> error_count ->> ode ->> oe ->> tu ->> tu_close
        ->> two_prob ->> omitted ->> zero_xn ->> tie -> plus;

    [% for x from First_multiplier to Last_multiplier do
            x*x; endfor; %] -> tie_list;

    newarray([2 ^N_problems],0)-> problem_error_count;

    fast_for x from First_multiplier to Last_multiplier do
        fast_for y from First_multiplier to Last_multiplier do

            2+((x-First_multiplier)*N_tables)+(y-First_multiplier) -> p;

            [% fast_for o from 1 to N_products do
                    matrix(p,o) -> occur;
                    if occur /= 0 then

                        if o = 1 then ;;; Omission error
                            omitted + occur -> omitted;
                            occur + error_count -> error_count;
                        else
                            [^(product_list(o)) ^occur];
                        endif;
                    endif;
                endfast_for; %] -> errors;

            foreach [?error ?occur] in errors do

                if count_types then
                    1 -> occur;     ;;; count types not tokens
                endif;

                occur + problem_error_count(p)
                    -> problem_error_count(p);

                ;;; Operand distance effect
                if cross(x,y,error,2) then
                    occur + ode -> ode;
                endif;

                ;;; operand errors/table unrelated...
                if sametable(x,y,error) then

;;;unless error = 0 and (x > 2 and y > 2) then
                    occur + oe -> oe;

                    ;;; percentage of which are high frequency products...
                    if member(error,[12 16 18 24 36]) then
                        occur + two_prob -> two_prob;
                    endif;
;;;endunless;
                else
                    occur + tu -> tu;
                    ;;; close in magnitude?
                    if tu_but_close(x,y,2,error) then
                        occur + tu_close -> tu_close;
                    else
                        ;;; [^error on ^x x ^y] =>
                    endif;
                endif;

                ;;; unlikely: operation errors
                if x+y = error then
;;;[^x + ^y = ^error occur ^occur plus ^plus]=>
                    occur + plus -> plus;
                endif;

                ;;; 0xN = N?
                if (x=0 or y=0) and not(a=0 and b=0) then
                    if error = max(x,y) then
                        zero_xn + occur -> zero_xn;
                    endif;
                endif;

                ;;; a tie problem
                if member(error,tie_list) then
                    tie + 1 -> tie;
                endif;


                occur + error_count -> error_count;

            endforeach;

        endfast_for;
    endfast_for;

    define safe_div(x,y);
        if y == 0 then 0; else x/y; endif;
    enddefine;

    define show(n,size);
        prnum(n,4,3); pr(' '); prnum(safe_div(100*n,size),3,3);
        pr('%'); nl(1);
    enddefine;


if JUST_RETURN then

[% 100.0*oe/error_count; 100.0*ode/error_count;
   100.0*omitted/error_count;  100*error_count/nblocks; %];

else

    pr('Total of '); pr(error_count); pr(' errors (');

    if count_types then
        pr('types only), ');
    else
        pr('tokens), ');
    endif;

    prnum(100*error_count/nblocks,3,3);
    pr('% of which...'); nl(1);

    ;;;error_count + 17 -> error_count;

    pr('Operand errors           '); show(oe,error_count);
    pr('Operand distance effect  '); show(ode,error_count);
;;;    pr('High frequency           '); show(two_prob,oe);
    pr('High frequency           '); show(two_prob,error_count);
    pr('Table errors  (% of all) '); show(tu,error_count);
    ;;;    pr('Table unrelated (close)  '); show(tu_close,error_count);
    ;;;    pr('Table unreated (distant) '); show(tu-tu_close,error_count);
    pr('Operation errors         '); show(plus,error_count);
    pr('Omission errors          '); show(omitted,error_count);
    pr('0xN = N                  '); show(zero_xn,error_count);
    pr('Tie error                '); show(tie,error_count);
    nl(1);

endif;

enddefine;


define mean_matrix(list) -> new_matrix;
    vars n = length(list),sum,i,a,b;
    newarray(boundslist(list(1)), procedure(a,b);
            0 -> sum;
            fast_for i from 1 to n  do
                list(i)(a,b) + sum -> sum;
            endfast_for;
sum;
;;;    round(1.0 * (sum/n));
        endprocedure) -> new_matrix;
enddefine;



define diff_matrix(m1,m2) -> n;
    vars n,i;
    newarray(boundslist(m1), procedure(a,b);
            fast_for i from 1 to length(list) do
                if m1(a,b) = 0 and m2(a,b) /= 0 then
                    false;
                elseif m1(a,b) /= 0 and m2(a,b) = 0 then
                    true;
                else
                    0;
                endif;
            endfast_for;
        endprocedure) -> n;
enddefine;

define write_problem_error_count;
vars dev = fopen('ped.dat',"w"),p;
for p from 2 to N_problems do
    fputstring(dev,''><(problem_error_count(p)));
endfor;
fclose(dev);
enddefine;


define list_pec;
    [% for p from 2 to N_problems do
            problem_error_count(p);
        endfor; %];
enddefine;


define what_errors(matrix);

    vars first_out, last_out, first_pat, last_pat;
    vars w=3, pw=5, a, b;

    boundslist(matrix) --> [?first_pat ?last_pat ?first_out ?last_out];


    define show_errors(x,y);
        vars p = 2+((x-First_multiplier)*N_tables)+(y-First_multiplier);
        vars ec = 0;
        for o from first_out to last_out do
            matrix(p,o)+ec -> ec;
        endfor;

    if ec /= 0 then
        pr_field('p'><x><'x'><y,pw,false,' ');
        for o from first_out to last_out do
            if matrix(p,o) /= 0 then
                pr('Error=');pr(product_list(o)); pr(' x');
                pr(intof(matrix(p,o)));
            pr('  ');
            endif;
        endfor; nl(1);
    endif;
    enddefine;

    for a from First_multiplier to Last_multiplier do
        for b from a to Last_multiplier do
            show_errors(a,b);
            unless a == b then
                show_errors(b,a);
            endunless;
        endfor;
    endfor;

enddefine;
