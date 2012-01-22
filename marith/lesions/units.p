

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
load ~/pop/pdp3/pdp3_perturb.p
load response_mechanism.p
load read_rt.p
load cascade_rt.p
load threshold_errors.p

load c_errrt.p
load zero_rt_cor.p

vars pats;

define test_errrt(base,net1,netn,min_threshold,max_threshold,blocks,
        Ndam) -> (E,R);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    net1 - 1 + netn -> netn;

    nl(2);
    [Zapping ^Ndam units]=>
    [^base ^net1 - ^netn min ^min_threshold Max^max_threshold and ^blocks blocks] =>

    fast_for i from net1 to netn do

        [now starting ^i] =>

        pdp3_getweights('01_new12',base><i) -> net;
        net.pdp3_nin -> h1;
        pdp3_firstoutputunit(net)-1 -> lh;
        lh-h1 -> hr;
        [] -> zapped;
        repeat Ndam times
            random0(hr)+h1+1 -> unit;
            while unit isin zapped do
                random0(hr)+h1+1 -> unit;
            endwhile;
            unit :: zapped -> zapped;
            [unit ^unit removed] =>
            pdp3_destroy(net, unit) -> net;
        endrepeat;

        pats -> pdp3_performance(net,0.2) -> (tss,pc,el,psl);
        [Classify ^pc per cent with tss ^tss] =>

        errrt(net,pats,2,101,100,0.05,min_threshold,
            max_threshold,blocks) -> (errors, rts, missing);

        if member(0,rts) then [zeros in ^base ^i] => endif;

        copytree(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


vars pats = pdp3_getpatterns('01_NORM',101,21,38,true);

vars fff,root_file = '01_norm30';

1 -> Ndam;

test_errrt(root_file><'-',1,20,0.8,0.9,25,Ndam) -> (E,R);

[% for i in E do
    newarray(boundslist(i), procedure(x,y); intof(i(x,y)); endprocedure);
endfor; %] -> cE;


copytree(cE) -> datafile('./lesions/RM'><Ndam><'.E');
mean_matrix(E) -> fff;
fff -> datafile('./lesions/RM'><Ndam><'.meanE');
count_errors(fff,false,20*25*100);


[Correlation of Omissions to PRODUCT] =>
vars i,j,prod;
[% for i from 0 to 9 do for j from 0 to 9 do i*j; endfor; endfor; %] -> prod;
[% for i from 2 to 101 do fff(i,1); endfor; %] -> om;
cor(om,prod);
[% for i from 0 to 9 do for j from 0 to 9 do i+j; endfor; endfor; %] -> prod;
[SUM correlation] =>
cor(om,prod);
nl(1);

[% for i in R do [% for j in i do intof(j); endfor %]; endfor; %] -> cR;

copytree(cR) -> datafile('./lesions/RM'><Ndam><'.R');
