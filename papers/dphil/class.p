uses rcg;
uses rc_graphplot;
uses rc_graphplot2;
rc_start();

vars freqsum = [
;;; less-than sum, frequ
[-1 foo]
[7 7]
[9 6]
[11 5]
[12 4]
[14 3]
[16 2]
[1000 1]
];


define class(a,b) -> freq;
    vars x,y,a,b,s,gt,lt, freq;

    a+b -> s;

    procedure(y); s >= y; endprocedure -> gt;
    procedure(y); s < y; endprocedure -> lt;

    freqsum --> [== [?y:gt =] [?x:lt ?freq]==];

enddefine;


vars f,x,y,tf,rel_freq;

[% for x from 2 to 9 do
0 -> tf;
    for y from 2 to 9 do
        class(x,y) + tf -> tf;
        unless x==y then
            class(y,x) + tf -> tf;
        endunless;
    endfor;
;;;[^x ^(1.0/tf)];
[^x ^(tf)];
endfor; %] -> rel_freq;

;;; For product list

[% for x from 2 to 9 do
0 -> tf;
    for y from 2 to 9 do
        class(x,y) -> tf;
[^(x*y) ^(tf/7)];
        unless x==y then
            class(y,x) -> tf;
[^(x*y) ^(tf/7)];
        endunless;
    endfor;
endfor; %] -> rel_freq;

syssort(rel_freq, procedure(a,b);
    a(1) < b(1); endprocedure) -> rel_freq;

define myfreq(p); (90-p)/88; enddefine;

newgraph();

rc_graphplot(4,1,81,'', myfreq,'')->region;
rc_print_here('Mine');


samegraph();

rc_graphplot2(rel_freq,'','')->;
rc_print_here('Mathnet');
