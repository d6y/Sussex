uses linearfit;

define mylinearfit(list) -> (m,c);
lvars m,c,list,xy;
[%
    until list == nil do
        fast_destpair(list) -> list -> xy;
        conspair(xy(1),xy(2));
    enduntil;
%]; .linearfit -> m -> c;
enddefine;

/*
mylinearfit([ [4 44] [8 63]]) -> (m,cq2);
m=>
** 25
c*1.0 =>
** 4.75
:. y = 4.75*x + 25
*/
