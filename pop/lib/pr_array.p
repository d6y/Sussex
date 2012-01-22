
define pr_vect(array);
    vars i,n,s;
    if isarray(array) then
        boundslist(array) --> [?s ?n];
    else
        1 -> s;
        length(array) -> n;
    endif;
    fast_for i from s to n do
        prnum(array(i),3,4); pr(' ');
    endfast_for; nl(1);
enddefine;

define pdp3_pr_vect(a);
vars i,n,s;
    if isarray(a) then
        boundslist(a) --> [?s ?n];
    else
        1 -> s;
        length(a) -> n;
    endif;

    fast_for i from s to n do
        prnum(intof(a(i)*100),3,0); pr(' ');
    endfast_for; nl(1);
enddefine;


define pr_weights(warr);
    vars i,j,a1,,a2,b1,b2;
    vars d1=3, d2=3;
    dlocal poplinemax, poplinewidth;
    boundslist(warr) --> [?a1 ?a2 ?b1 ?b2];
    10 + a2 * (2+d1+d2) ->> poplinemax -> poplinewidth;
    pr('  ');
    fast_for i from a1 to a2 do
        pr_field(i,d1+d2,' ',false);
    endfast_for; nl(1);

    fast_for j from b1 to b2 do
        pr_field(''><j,4,' ',' ');
        fast_for i from a1 to a2 do
            prnum(warr(i,j),d1,d2);
        endfast_for; nl(1);
    endfast_for;
enddefine;

define pr_array(a);
    vars x1,x2,y1,y2;
    if isarray(a) then
        if boundslist(a) matches [?x1 ?x2 ?y1 ?y2] then
            pr_weights(a);
        elseif boundslist(a) matches [?x1 ?x2] then
            pr_vect(a);
        else
            mishap('Not one or two d array',[^(boundslist(a))]);
        endif;
    else
        a =>
    endif;
enddefine;


define pr_table(warr);
    vars i,j,a1,a2,b1,b2,c,k=0;
    vars d1=3, d2=0;
    dlocal poplinemax, poplinewidth;
    boundslist(warr) --> [?a1 ?a2 ?b1 ?b2];
    10 + b2 * (2+d1+d2) ->> poplinemax -> poplinewidth;
    pr('  ');
    fast_for i from b1 to b2 do
        pr_field(i,d1+d2,' ',false);
    endfast_for; pr('    total'); nl(1);

    fast_for j from a1 to a2 do
        pr_field(''><j,3,' ',' ');
        0 -> c;
        fast_for i from b1 to b2 do
if warr(j,i) =0 then pr_field('',d1+d2,' ',false); else
            prnum(warr(j,i),d1,d2);
endif;
            c + warr(j,i) -> c;
        endfast_for;
        k + c -> k;
        pr(' |'); prnum(c,d1,d2); nl(1);
    endfast_for;

    pr_field('',3,' ',' ');
    repeat 1+b1*(d1+d2) times pr('-'); endrepeat; pr('+\n');
    pr_field('tot',3,' ',' ');
    fast_for i from b1 to b2 do
        0 -> c;
        fast_for j from a1 to a2 do
            c + warr(j,i) -> c;
        endfast_for;
        prnum(c,d1,d2);
    endfast_for;

    pr('  '); prnum(k,d1,d2); nl(1);
enddefine;


define pr_table_r(warr);
    vars i,j,a1,a2,b1,b2,c,k=0;
    vars d1=3, d2=0;
    dlocal poplinemax, poplinewidth;
    boundslist(warr) --> [?a1 ?a2 ?b1 ?b2];
    10 + a1 * (2+d1+d2) ->> poplinemax -> poplinewidth;
    pr('  ');
    fast_for i from a1 to a2 do
        pr_field(i,d1+d2,' ',false);
    endfast_for; pr('    total'); nl(1);

    fast_for j from b1 to b2 do
        pr_field(''><j,3,' ',' ');
        0 -> c;
        fast_for i from a1 to a2 do
            prnum(warr(i,j),d1,d2);
            c + warr(i,j) -> c;
        endfast_for;
        k + c -> k;
        pr(' |'); prnum(c,d1,d2); nl(1);
    endfast_for;

    pr_field('',3,' ',' ');
    repeat 1+a1*(d1+d2) times pr('-'); endrepeat; pr('+\n');
    pr_field('tot',3,' ',' ');
    fast_for i from a1 to a2 do
        0 -> c;
        fast_for j from b1 to b2 do
            c + warr(i,j) -> c;
        endfast_for;
        prnum(c,d1,d2);
    endfast_for;

    pr('  '); prnum(k,d1,d2); nl(1);
enddefine;
