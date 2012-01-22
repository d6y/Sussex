define arraytolist(a);
vars p,x,y;
boundslist(a) --> [?x ?y];
[% fast_for p from x to y do
    a(p);
endfast_for; %];
enddefine;
