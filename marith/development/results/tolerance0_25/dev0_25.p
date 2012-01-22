2500000 -> popmemlim;

'~richardd/pop/lib' :: popliblist -> popliblist;
'~richardd/pop/lib' :: popuseslist -> popuseslist;
'~richardd/pop/help' :: vedhelplist -> vedhelplist;
['$HOME' '$HOME/mail' '$poplib'] -> vedsearchlist;


uses statlib;
uses sysio;
uses stringtolist;
load ~/pop/pdp3/pdp3.p
load ~/marith/read_rt.p
load ~/marith/threshold_errors.p
load ~/marith/latex_matrix.p
load ~/marith/c_errrt.p
vars pats;
load ~/marith/product_code.p     ;;; a

define test_errrt(net_file,base,min_threshold,max_threshold,
        blocks);
    vars i,E,R,missing,rts,errors;
    vars tss,pc,el,psl;
    [] -> E;
    [] -> R;

    nl(2);
    [^base min ^min_threshold Max ^max_threshold and ^blocks blocks] =>

    for i in netL do
        [now starting ^i] =>

        pdp3_getweights(net_file,base><i) -> net;

        pats -> pdp3_performance(net,0.25) -> (tss,pc,el,psl);
        [Classify ^pc per cent with tss ^tss] =>

        errrt(net,pats,2,N_problems,100,0.05,min_threshold,
            max_threshold,blocks) -> (errors, rts, missing);

        count_errors(errors,false,25*64,true) -> list;
        list --> [?oe ?ode ?omit ?err];

        fputstring(oedev,i><'   '><(1.0*oe));
        fputstring(odedev,i><'   '><(1.0*ode));
        fputstring(omitdev,i><'   '><(1.0*omit));
        fputstring(errdev,i><'   '><(1.0*err));

    endfor;
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




vars pats = pdp3_getpatterns('~/marith/patterns/NORMAL',65,17,32,true);

vars netL = [1 5 10 20 30 40 50 60 70 80 90 100];

vars oedev = fopen('~/marith/development/oe.plt',"w");
vars odedev = fopen('~/marith/development/ode.plt',"w");
vars omitdev = fopen('~/marith/development/omit.plt',"w");
vars errdev = fopen('~/marith/development/err.plt',"w");

fputstring(oedev,'\"Operand errors\"');
fputstring(odedev,'\"Close operand errors\"');
fputstring(omitdev,'\"Omission errors\"');
fputstring(errdev,'\"Recall errors\"');


test_errrt('~/marith/networks/new10',
    '~/marith/development/weights/tolerance0_25/dev-', 0.4, 0.9, 25);

fclose(oedev);
fclose(odedev);
fclose(omitdev);
fclose(errdev);
