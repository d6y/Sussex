

;;; Input representation used by MATHNET

define mathnet_input(n) -> s;
    lvars i, prev, next, s ='';

    n+1 -> n;
    n-1 -> prev;
    n+1 -> next;

    fast_for i from 0 to 14 do
        if i = n or i = prev or i = next then
            s >< '1 ' -> s;
        else
            s >< '0 ' -> s;
        endif;
    endfast_for;
enddefine;


for i from 0 to 12 do
spr(i><'    '); pr(mathnet_input(i)); nl(1);


endfor;
