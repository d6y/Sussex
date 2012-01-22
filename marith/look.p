/*
uses rcg
uses statlib
uses sysio
load ~/pop/pdp3/pdp3.p
load product_ZERO.p
load product_code.p
load graphics/plothidden.p
load trace_hidden.p
load graphics/hinton.p
load graphics/plot_hidden_reaction.p
load graphics/plot_weighted.p
load trace_chain.p

vars net = pdp3_getweights('networks/01_new12','weights/01_norm30-1');
vars pats = pdp3_getpatterns('patterns/01_NORM',101,21,38,true);


vars pats = pdp3_getpatterns('patterns/EQ-ONE',65,17,32,true);

vars net = pdp3_getweights('networks/new10',
        'weights/one-of-n/weights/equ10-1');


*/



rc_start();
rc_default();
plot_weighted(net,pats);

vars time_limit2 = 55;
40-> time_limit;
;;; 6x8 = error 54
trace_chain(net,pats,'p6x9','p6x8',0) -> h;
trace_chain(net,pats,'p8x4','p6x8',0) -> h;

trace_chain(net,pats,'p3x3','p6x8',0) -> h;

vars prob = 'p6x8';
'p5x2' -> prob;
;;;trace_prime(net,pats,'p3x9',prob) -> h;
trace_reaction(net,pats,prob) -> h;



h(35) =>

rc_start();

vars hh = [% for i from 1 to time_limit do
    h(i)(11); endfor; %];
sort(hh) =>

trace_hidden(net,pats,prob) -> h;

plot_hidden_reaction(net,pats,prob);

/*
load c_errrt.p
load threshold_errors.p
*/
errrt(net,pats,2,65,100,0.05,0.4,0.9,50) -> (E,R,M);
errrt(net,pats,2,101,100,0.05,0.4,0.9,10) -> (E,R,M);
plot_list(R);
rc_print_at(2,35,pdp3_wtsfile(net));

what_errors(E);

[% for i from 1 to 20 do

vars net = pdp3_getweights('new10','PROB10ec0_05-'><i);
pdp3_recordhidden(net,pats) -> vector;
[%for a from 2 to 9 do
[%    for b from 2 to 9 do
        0->c;
        (a-2)*8 + (b-2) + 2 -> p;
        for act in vector(p) using_subscriptor subscrv do
            if act >= 0.5 then 1+c->c; endif;
        endfor;
    c;
    endfor;%] -> L;
[^a ^(addup(L)) ^(mean(L)) ^(SD(L))];
endfor; %] -> f;
    sort_by_n_num(f,3) -> f;
    [% for j from 1 to 8 do [% f(j)(1); j; %] endfor; %];
    f ==>
endfor; %] -> g;

[% for j from 2 to 9 do
    [% j;
    mean([% for i from 1 to 20 do

g(i) --> [==[^(j) ?p]==]; p;

endfor; %]); %];
endfor; %] -> k;

sort_by_n_num(k,2) ==>



plothidden(net,pats,50);


false->rc_clipping;
show_hidden_fanout(net,11,11,0.8);
show_hidden_fanin(net,30,25,1);

pdp3_recordhidden(net,pats,false) -> V;
rc_default();
show_hidden_activity(V,10,10,8,net);


;;; for ps edit graphics/hinton.p and change
;;; rcg_plt_box to rcg_plt_box2 in
;;; plt_hinton

rc_start(); rc_default(); lib rc_ps;
rc_postscript('/tmp/wts.ps', procedure();
Xweighted(net,pats,14,14,0.35,false);
endprocedure,[6 6 0.5 1], true);

lib rc_ps;
rc_postscript('hint.ps', procedure();
XpwSetFont(rc_window,'-adobe-times-medium-b-normal--10-200-75-75-p-54-iso8859-1')=>
;;;'-adobe-helvetica-medium-r-normal--*-160-*-*-p-*-iso8859-1')->;
Xshow_hidden_activity(V,12,12,7,net);
endprocedure,[6 6 1.5 0.5], true);
plot_fanin(net,1);
plot_fanout(net,1);
rc_print_at(-200,150,pdp3_adddot(net,'wts'));


define naming(unit,net) -> label;
    vars out1 = pdp3_firstoutputunit(net);
    if unit < pdp3_nin(net) then ;;; input layer
        [TIE 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9](1+unit) -> label;
    elseif unit < out1 then ;;; hidden
        unit -> label;
    else ;;; output
        (product_list(1+unit-out1)) -> label;
    endif;
enddefine;



2 -> pdp3_printweights_rowspace;
pdp3_printweights(net,naming);
pdp3_printweights(net);



pdp3_selectpattern('p6x7',pats) -> (s,t);
s =>


define en(n);
    vars i,d,s;
    0.85 -> s;
    {% for i from First_multiplier to Last_multiplier do
            abs(i-n) ->d;
            exp(-0.5*(d/s)**2);
        endfor; %};
enddefine;


{0.0 0.0 0.000016 0.001973 0.062777 0.500553 1.0 0.500553 0.062777 0.001973}
-> six;
{0.0 0.0 0.0 0.000016 0.001973 0.062777 0.500553 1.0 0.500553 0.062777} -> seven;

{0 0 0 0 0 0 0 0 0 0} -> blank;

{0 ^^blank ^^six} ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{0 ^^blank ^^seven} ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{0 ^^six ^^blank} ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{0 ^^six ^^seven} -> pdp3_activate(net) -> pdp3_output(net) -> o;

{1 ^^six ^^six}  -> pdp3_activate(net) -> pdp3_output(net) -> o;

{1 ^^blank ^^blank} -> pdp3_activate(net) -> pdp3_output(net) -> o;


{0 ^^(en(5)) ^^blank} ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{0 ^^blank ^^(en(6)) } ->  pdp3_activate(net) -> pdp3_output(net) -> o;

{0 ^^(en(5)) ^^(en(6)) } ->  pdp3_activate(net) -> pdp3_output(net) -> o;

{1 ^^(en(5)) ^^blank } ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{1 ^^blank ^^(en(5))} ->  pdp3_activate(net) -> pdp3_output(net) -> o;
{1 ^^(en(5)) ^^(en(5))} ->  pdp3_activate(net) -> pdp3_output(net) -> o;

for i from 1 to N_products do
if o(i) > 0.00001 then
spr(product_list(i)); pr(o(i)); nl(1);
endif;
endfor;

pdp3_contribution(net) -> contrib;
contrib =>
pr_array(contrib);
contrib(3,40) =>

rc_plot_array(contrib,0.01,10,
[T 0 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9],product_list);


vars usedprods=[];
define tietable;
    [] -> usedprods;

    vars stims =
        [
        [0 ^blank ^seven]
        [0 ^seven ^blank]
        [0 ^six   ^blank]
        [0 ^six   ^seven]
        [1 ^blank ^blank]
    ];

    vars tiebit, op1, op2, i,o, products=[];
    [%
        foreach [?tiebit ?op1 ?op2] in stims do
            [% tiebit; copydata(op1); copydata(op2); [%
                    {^tiebit ^^op1 ^^op2} -> pdp3_activate(net) -> pdp3_output(net) -> o;
                    for i from 1 to N_products do
;;;                        if o(i) > 0.00001 then
                        if o(i) > 0.0001 then
                            product_list(i) -> prod;
                            unless prod isin usedprods then
                                prod :: usedprods -> usedprods;
                            endunless;
                            [^prod ^(o(i))];
                        endif;
                    endfor;
                %]; %];
        endforeach;
    %] -> activation_list;

/*
    if '?' isin usedprods then
        delete('?', usedprods) -> usedprods;
        sort(usedprods) -> usedprods;
        ['?' ^^usedprods] -> usedprods;
    else
             sort(usedprods) -> usedprods;
    endif;
    last(usedprods) -> last_prod;
    */

    vars biggest,v,dev = fopen('tab.tex',"w");

    0->biggest;
    foreach [?tiebit ?op1 ?op2 ?actlist] in activation_list do
        length(actlist) -> v;
        if v > biggest then v-> biggest; endif;
    endforeach;


    finsertstring(dev,'\\begin{table}\\begin{tabular}{ccc|');
    repeat biggest times finsertstring(dev,'c'); endrepeat;
    fputstring(dev,'}');

    finsertstring(dev,'Tie&');
    finsertstring(dev,'1st Op&');
    finsertstring(dev,'2nd Op&');

/*    for prod in usedprods do
    if prod=last_prod then
    finsertstring(dev,prod><'\\\\');
    else
        finsertstring(dev,prod><'&');
    endif;
    endfor;
*/
    repeat biggest-1 times finsertstring(dev,'&'); endrepeat;
    fputstring(dev,'\\\\');
    fputstring(dev,'\\hline');

    foreach [?tiebit ?op1 ?op2 ?actlist] in activation_list do
;;;actlist==>
        if tiebit==1 then
            finsertstring(dev,'$\\bullet$&');
            else
            finsertstring(dev,'&');
        endif;

        if op1 = blank then
            finsertstring(dev,'Blank&');
        elseif op1 = six then
            finsertstring(dev,'6&');
        elseif op1 = seven then
            finsertstring(dev,'7&');
        else [error ^op1]=>
        endif;

        if op2 = blank then
            finsertstring(dev,'Blank&');
        elseif op2 = six then
            finsertstring(dev,'6&');
        elseif op2 = seven then
            finsertstring(dev,'7&');
        else [error2] =>
        endif;

        /*
    for prod in usedprods do
        if actlist matches [==[^prod ?act]==] then
         intof(act*10000) -> v;
        unless v = 0 then
            finsertstring(dev, v><'');
        endunless;
        endif;
        unless prod = last_prod then finsertstring(dev,'&'); endunless;
    endfor;
*/

        sort_by_n_num(actlist,2) -> actlist;
        last(actlist)(1) -> last_prod;
        length(actlist) -> v;
        foreach [?prod ?act] in actlist do
            finsertstring(dev,prod><'');
            if prod=last_prod then
                fputstring(dev,'\\\\');
                else
                finsertstring(dev,'&');
            endif;
        endforeach;

        unless prod=last_prod then
            repeat (biggest-v)-1 times
                finsertstring(dev,'&');
            endrepeat;
            fputstring(dev,'\\\\');
        endunless;


    endforeach;

    fputstring(dev,'\\end{tabular}\\end{table}');
    fclose(dev);
enddefine;

tietable();
