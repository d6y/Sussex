uses rc_graphplot;

vars t,b,e,s;

define th(n);
    tanh(n/t);
enddefine;

-100 -> b;
100 -> e;
1 -> s;
0 -> t;

rc_start();
rc_graphplot(b,s,e,'',th,'')->region;
