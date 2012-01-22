

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
;;;load response_mechanism.p
load read_rt.p
;;;load cascade_rt.p
load threshold_errors.p
load latex_matrix.p
load c_errrt.p
load zero_rt_cor.p
vars pats;



define Proc(v) -> v;

    if v > 0 then
        v - Value -> v;
    else
        v + Value -> v;
    endif;

    v + ( random(Value/2)-Value/4 ) -> v;
;;;    v + ( random(Value/4)-Value/8 ) -> v;
enddefine;


define test_errrt(base,net1,netn,min_threshold,max_threshold,
        blocks,) -> (E,R);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    net1 - 1 + netn -> netn;

    nl(2);
    [^base ^net1 - ^netn min ^min_threshold Max^max_threshold and ^blocks blocks] =>

    fast_for i from net1 to netn do

        [now starting ^i] =>

        pdp3_getweights('~/marith/networks/01_new12',base><i) -> net;

        pdp3_apply_damage(net, Proc) -> net;

        pats -> pdp3_performance(net,0.2) -> (tss,pc,el,psl);
        [Classify ^pc per cent with tss ^tss] =>

        errrt(net,pats,2,101,100,0.05,min_threshold,
            max_threshold,blocks) -> (errors, rts, missing);

        if member(0,rts) then [zeros in ^base ^i] => endif;

        copydata(errors) :: E -> E;
        copytree(rts) :: R -> R;
    endfast_for;
enddefine;


define editweights(Name);
[Running procedure for ^Name] =>
    vars pats = pdp3_getpatterns('~/marith/patterns/01_NORM',101,21,38,true);

    vars fff,root_file = '~/marith/weights/01_norm30';

    test_errrt(root_file><'-',1,20,0.8,0.9,25) -> (E,R);

[% for i in E do
    newarray(boundslist(i), procedure(x,y); intof(i(x,y)); endprocedure);
endfor; %] -> cE;

    copytree(cE) -> datafile('~/marith/lesions/'><Name><'.E');
    mean_matrix(E) -> fff;
    fff -> datafile('~/marith/lesions/'><Name><'.meanE');
    count_errors(fff,false,20*25*100);

    [Correlation of Omissions to PRODUCT] =>
    vars i,j,prod;
    [% for i from 0 to 9 do for j from 0 to 9 do i*j; endfor; endfor; %] -> prod;
    [% for i from 2 to 101 do fff(i,1); endfor; %] -> om;
    cor(om,prod);

ascii_performance(fff,'Relaxed equal reduction (value='><Value><')',25*20) -> ermat;

[% fast_for x from 0 to 9 do
    fast_for y from 0 to 9 do
        ermat(x,y);
    endfast_for;
endfast_for; %] -> error_rate;
[Error rate / Product] =>
cor(error_rate, prod);
nl(1);

;;;    copytree(R) -> datafile('./lesions/'><Name><'.R');

enddefine;

vars Value;

sysdaytime() =>
for Value in [1.625] do
editweights('RLXADD_24'><Value);
sysdaytime() =>
endfor;
