
2500000 -> popmemlim;
sysdaytime() =>

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


vars threshold, time_limit, spec, name;

load product_ZERO.p
uses statlib;
uses sysio;
uses stringtolist;
load ~/pop/pdp3/pdp3.p
load response_mechanism.p
load read_rt.p
load cascade_rt.p
load threshold_errors.p

load c_errrt.p
load zero_rt_cor.p

vars pats;

define test_errrt(base,net1,netn,min_threshold,max_threshold,blocks) -> (E,R);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    net1 - 1 + netn -> netn;

    nl(2);
    [^base ^net1 - ^netn min ^min_threshold Max^max_threshold and ^blocks blocks] =>

    fast_for i from net1 to netn do

[now starting ^i] =>

        pdp3_getweights('networks/01_new12',base><i) -> net;

    pats -> pdp3_performance(net,0.2) -> (tss,pc,el,psl);
    [Classify ^pc per cent with tss ^tss] =>

errrt(net,pats,2,101,100,0.05,min_threshold,
    max_threshold,blocks) -> (errors, rts, missing);

if member(0,rts) then [zeros in ^base ^i] => endif;

        copytree(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


vars pats = pdp3_getpatterns('patterns/01_NORM',101,21,38,true);
