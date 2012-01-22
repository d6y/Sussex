;;; Run this to analyse the results of training for the problems
;;; c) 0x0 to 12x12
;;; b) 0x0 to 9x9
;;; c) 2x2 to 9x9

2500000 -> popmemlim;

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


uses statlib;
uses sysio;
uses stringtolist;
load ~/pop/pdp3/pdp3.p
load read_rt.p
load threshold_errors.p
load latex_matrix.p
load c_errrt.p
vars pats;
load product_ZERO.p ;;; required by next line
load zero_rt_cor.p
load Structured_variables.p

;;; CUSTOMIZE HERE
load product_10-12.p    ;;; c
;;; load product_code.p     ;;; a
;;; load product_ZERO.p     ;;; b
;;; SEE ALSO END OF FILE

define test_errrt(net_file,base,net1,netn,min_threshold,max_threshold,
        blocks) -> (E,R);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    net1 - 1 + netn -> netn;

    nl(2);
    [^base ^net1 - ^netn min ^min_threshold Max^max_threshold and ^blocks blocks] =>

    fast_for i from net1 to netn do
        [now starting ^i] =>

        pdp3_getweights(net_file,base><i) -> net;
        pats -> pdp3_performance(net,0.25) -> (tss,pc,el,psl);
        [Classify ^pc per cent with tss ^tss] =>

        errrt(net,pats,2,N_problems,100,0.05,min_threshold,
            max_threshold,blocks) -> (errors, rts, missing);

        if member(0,rts) then [zeros in ^base ^i] => endif;

        copydata(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


define cut_down(r);
    vars p=1,i,j;
    [% for j from 0 to 9 do
            for i from 0 to 9 do
                r(p);
                p+1->p;
            endfor;
            p+3 -> p;
        endfor; %];
enddefine;

define testnet(net_file, base);
    vars lowest_threshold = 0.4;
    vars highest_threshold = 0.9;
    vars first_network_number = 1;
    vars last_network_number = 10;
    vars number_of_trials = 25;

    test_errrt(net_file,base, first_network_number, last_network_number,
        lowest_threshold, highest_threshold, number_of_trials) -> (E,R);

    [% for i in E do
            newarray(boundslist(i), procedure(x,y); intof(i(x,y)); endprocedure);
        endfor; %] -> cE;

    copytree(cE) -> datafile(base><'.E');
    mean_matrix(E) -> av;
    av -> datafile(base><'.meanE');
    count_errors(av,false, number_of_trials * (N_products-1) *
        (1+last_network_number-first_network_number) );

    [% for i from 1 to N_problems-1 do
            mean([% for j from first_network_number to last_network_number do
                        unless R(j)(i) = 0 then R(j)(i); endunless;
                    endfor; %]);
        endfor; %] -> r;

    nl(2); pr('plot_list('); pr(r); pr(');'); nl(2);

    [% for p from 2 to N_problems do
            problem_error_count(p);
        endfor; %] -> pec;

    [RT and prob. err. count] =>
    cor(r,pec);

    structured_variables(r);

    [Correlation for 0x0 to 9x9 problems, only] =>
    cut_down(r) -> little_r;
    zero_rt_cor(little_r);

    r -> datafile(base><'.r');

    [% for i from 1 to N_problems-1 do
            [% for j from first_network_number to last_network_number do
                    intof(R(j)(i));
                endfor; %];
        endfor; %] -> datafile(base><'.R');

enddefine;

vars pats = pdp3_getpatterns('~/marith/patterns/12_NORM',170,31,61,true);

;;;testnet('~/marith/twelve','~/marith/weights/12_norm-');
testnet('~/marith/networks/twelve','~/marith/weights/12_prob-');
