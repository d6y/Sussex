
define datapoint(a1,a2,l);
    l(1+(a2-First_multiplier)+((a1-First_multiplier)*N_tables));
enddefine;

vars c = 1;


define plot_list(list);
vars p1,p2,a, b;

    vars meandata = [%
            fast_for a from First_multiplier to Last_multiplier do
                [% fast_for b from First_multiplier to Last_multiplier do
                unless a = b then
                    datapoint(a,b,list) -> p1;
                    datapoint(b,a,list) -> p2;
                    if p2 /=0 then p2; endif;
                    if p1 /=0 then p1; endif;

                else
                    datapoint(a,b,list) -> p1;
                    unless p1 = 0 then p1; endunless;
                endunless;
                endfast_for; %] -> lll;
mean(lll) -> lll;
spr(a); pr(lll); nl(1);
lll;
            endfast_for; %];

    "line" -> rcg_pt_type;
    {% for a from First_multiplier to Last_multiplier do a; endfor %} -> xax;
    rc_graphplot(xax,'',meandata,'RT') -> region;

fast_for a from First_multiplier to Last_multiplier do
    rcg_plt_cross(a,datapoint(a,a,list));
newgraph();
endfast_for;


   newgraph();
enddefine;

define plot_collapse(list);
vars dd,p=1, ltble = [% for a from 2 to 9 do
    for b from a to 9 do [% a; b; p; p+1->p; %]; endfor;
        endfor; %];

vars a,b, eight = [%
    for a from 2 to 9 do
        mean([% for b from 2 to 9 do
            ltble --> [==[^(min(a,b)) ^(max(a,b)) ?p]==];
            list(p);
        endfor; %]) -> dd; dd; dd=>
    endfor; %];
rc_graphplot({2 3 4 5 6 7 8 9},'',eight,'') -> region;
enddefine;
