uses sysio;
load product_code.p


define encode(n,l) -> string;
    vars i,string='';
    fast_for i from 2 to l+1 do
        string ><
        if i == n then '1 '
        else '0 '
        endif; -> string;
    endfor;
enddefine;

vars sequence = [2 3 4 5 6 7 8 9];


define gen(base,em,col,reptab);
    vars d,kp,i,j,k,dev,filebase;

    base -> filebase;
    if em then filebase >< 'em' -> filebase; endif;
    if col then filebase >< 'cl' -> filebase; endif;
    if reptab then filebase >< 'rp' -> filebase; endif;  ;;; only if col is true

    fast_for i from 1 to 8 do

        fopen(filebase><i><'.pat',"w") -> dev;

        fputstring(dev,'zero 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ');

        fast_for kp from 1 to i do

            [% fast_for l from 1 to kp-1 do sequence(l); endfast_for; %] -> d;

            sequence(kp) -> k;

            fast_for j from 2 to 9 do
                unless (j isin d) and reptab = false  then
                    fputstring(dev,'p'><k><'x'><j><' '><(encode(k,8))><' '><(encode(j,8))><' '><(code(j*k)));
                endunless;
            endfast_for;

            fputstring(dev,'p'><k><'x'><k><' '><(encode(k,8))><' '><(encode(k,8))><' '><(code(k*k)));
            fputstring(dev,'p'><k><'x'><k><' '><(encode(k,8))><' '><(encode(k,8))><' '><(code(k*k)));

        endfast_for;

        fclose(dev);
    endfast_for;


enddefine;

gen('ties',false,false,true);
