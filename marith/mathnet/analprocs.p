
2500000 -> popmemlim;
sysdaytime() =>

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


vars threshold, time_limit, spec, name;

load ../product_ZERO.p
uses statlib;
uses sysio;
uses stringtolist;
load ~/pop/pdp3/pdp3.p
load ../read_rt.p
load ../threshold_errors.p

load ../c_errrt.p
load ../zero_rt_cor.p

vars pats;

define test_errrt(dotnet,base,net1,netn,min_threshold,max_threshold,blocks) -> (E,R);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    net1 - 1 + netn -> netn;

    nl(2);
    [^base ^net1 - ^netn min ^min_threshold Max^max_threshold and ^blocks blocks] =>

    fast_for i from net1 to netn do

[now starting ^i] =>

        pdp3_getweights(dotnet,base><i) -> net;

    pats -> pdp3_performance(net,0.49) -> (tss,pc,el,psl);
    [Classify ^pc per cent with tss ^tss] =>

errrt(net,pats,2,101,100,0.05,min_threshold,
    max_threshold,blocks) -> (errors, rts, missing);

if member(0,rts) then [zeros in ^base ^i] => endif;

        copytree(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


vars pats = pdp3_getpatterns('mn_norm',101,25,38,true);



define test20(dotnet,root_file);

    test_errrt(dotnet,root_file><'-',1,10,0.4,0.9,50) -> (E,R);

    mean_matrix(E) -> fff;

    count_errors(fff,false,10*50*100);

    vars r = [% for i from 1 to 100 do
        mean([% for j from 1 to 10 do unless
                R(j)(i)=0 then R(j)(i); endunless; endfor; %]);
    endfor; %];


r -> datafile(root_file><'.rt');
fff -> datafile(root_file><'.meanE');

zero_rt_cor(r);

    [% for i from 2 to N_problems do
        problem_error_count(i); endfor; %] -> ped_list;

[Error rate and RT]=>
cor(ped_list,r);

load ../Structured_variables.p

nl(3);
enddefine;
