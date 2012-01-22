vars dev = fopen('appa.dat',"r");

vars sum_list = [% fast_for a from 2 to 9 do
                        fast_for b from 2 to  9 do
                                              ''><a><'x'><b;
endfast_for; endfast_for; %];

vars sum_list2 = [% for a from 2 to 9 do
    for b from a to 9 do  ''><a><'x'><b;
        unless a == b then b><'x'><a; endunless;
    endfor; endfor; %];

vars string;
vars hdata = [% repeat 64 times

        fgetstring(dev) -> string;

    12 -> i;

    [% repeat
            issubstring('&',i,string) -> p;

            if p = false then
                issubstring('\\',i,string) -> p;
            substring(i,p-i,string) -> c;
            if c = '  ' or c = ' ' or c = 'c' or c = ' c' then 0;
            else strnumber(c); endif;
        quitloop; endif;

            substring(i,p-i,string) -> c;

            if c = '  ' or c = ' ' or c = 'c' or c = ' c' then 0;
            else strnumber(c); endif;

            p+1 -> i;

        endrepeat; %];

endrepeat; %];

fclose(dev);

[s] =>
vars matrix = newarray([1 64 1 31],procedure(y,x);
    hdata(y)(x); endprocedure);

[0] =>
vars d,i,j, st = [% fast_for i from 1 to 64 do
    [% fast_for j from 1 to 31 do matrix(i,j); endfast_for; %] -> d;
    [% mean(d); SD(d); %];
endfast_for; %];

[a] =>
vars mu,sd;
fast_for i from 1 to 64 do
    st(i)(1) -> mu;
    st(i)(2) -> sd;
    fast_for j from 1 to 31 do
        if sd = 0 then 0 -> matrix(i,j); else
        (matrix(i,j)-mu)/sd -> matrix(i,j);  endif;
    endfast_for;
endfast_for;


[c] =>
define pr_table(warr);
    vars i,j,a,b,c,k=0;
    vars d1=3, d2=4;
    dlocal poplinemax, poplinewidth;
    boundslist(warr) --> [1 ?np 1 ?no];
    10 + no * (2+d1+d2) ->> poplinemax -> poplinewidth;
    pr('  ');
    fast_for i from 1 to no do
        pr_field(prod_list(i),d1+d2,' ',false);
    endfast_for; pr('    total'); nl(1);

    fast_for j from 1 to np do
        pr_field(''><sum_list2(j),3,' ',' ');
        0 -> c;
        fast_for i from 1 to no do
            if warr(j,i) = 0 then
                pr_field('',d1+d2,' ',' ');
            else prnum(warr(j,i),d1,d2);
            endif;
            c + warr(j,i) -> c;
        endfast_for;
        k + c -> k;
        pr(' |'); prnum(c,d1,d2); nl(1);
    endfast_for;

    pr_field('',3,' ',' ');
    repeat 1+no*(d1+d2) times pr('-'); endrepeat; pr('+\n');
    pr_field('tot',3,' ',' ');
    fast_for i from 1 to no do
        0 -> c;
        fast_for j from 1 to np do
            c + warr(j,i) -> c;
        endfast_for;
        prnum(c,d1,d2);
    endfast_for;

    pr('  '); prnum(k,d1,d2); nl(1);

enddefine;
