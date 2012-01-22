uses sysio;

define encode(n,l) -> string;
    vars i,string='';
    fast_for i from 2 to l+1 do
        string ><
        if i > n then '0 '
        else '1 '
        endif; -> string;
    endfor;
enddefine;

vars sequence = [2 3 4 5 6 7 8 9];

define gen;
    vars d,kp,i,j,k,dev,filebase='therm',headstring,ties;

    fast_for i from 1 to 8 do

        fopen(filebase><i><'.pat',"w") -> dev;

        fputstring(dev,'zero 0 0  0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ');

        '1 0 ' -> headstring;

        fast_for kp from 1 to i do

            [% fast_for l from 1 to kp-1 do sequence(l); endfast_for; %] -> d;

            sequence(kp) -> k;

            fast_for j from 2 to 9 do
                if j == k then ' 1  ' -> ties; else ' 0  ' -> ties; endif;
                fputstring(dev,'p'><k><'x'><j><' '><headstring><ties><(encode(k,8))><' '><(encode(j,8))><' '><(code(j*k)));
            endfast_for;

        endfast_for;

        fclose(dev);
    endfast_for;

enddefine;
gen();
