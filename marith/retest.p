;;; Run this to analyse the results of training for the problems
;;; c) 0x0 to 12x12
;;; b) 0x0 to 9x9
;;; c) 2x2 to 9x9

2500000 -> popmemlim;

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


load product_ZERO.p     ;;; b

uses statlib;
uses sysio;
uses stringtolist;
load ~/pop/pdp3/pdp3.p
load read_rt.p
load threshold_errors.p
load latex_matrix.p
load c_errrt.p
vars pats;
load Structured_variables.p


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

        errrt(net,pats,2,N_problems,100,0.05,min_threshold,
            max_threshold,blocks) -> (errors, rts, missing);

        if member(0,rts) then [zeros in ^base ^i] => endif;

        copydata(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


define testnet(net_file, base);
    vars lowest_threshold = 0.4;
    vars highest_threshold = 0.9;
    vars first_network_number = 1;
    vars last_network_number = 20;
    vars number_of_trials = 25;

    test_errrt(net_file,base, first_network_number, last_network_number,
        lowest_threshold, highest_threshold, number_of_trials) -> (E,R);

    mean_matrix(E) -> av;

    count_errors(av,false, number_of_trials * (N_products-1) *
        (1+last_network_number-first_network_number) );

    [% for p from 2 to N_problems do
            problem_error_count(p);
        endfor; %] -> pec;

    [product and prob. err. count] =>
    cor(pec,sv_prod);

enddefine;


;;;vars pats = pdp3_getpatterns('patterns/01_NORM',101,21,38,true);
;;;testnet('~/marith/networks/01_new12','/tmp/richardd/01_norm30-');
;;;latex_matrix(av, 'Mean of 20 networks, 0-9');
;;;sysobey('mv emat.tex 01_emat.tex');

load product_code.p
vars pats = pdp3_getpatterns('patterns/NORMAL',65,17,32,true);
testnet('~/marith/networks/new10','/tmp/richardd/NORM10after05-');
latex_matrix(av, 'Mean of 20 networks, 2-9');
sysobey('mv emat.tex 29_emat.tex');
