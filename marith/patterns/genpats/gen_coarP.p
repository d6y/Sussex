uses sysio;

define comp_prob(n) -> p;
vars n;
((90-n/1)/88)*1.0 -> p;
enddefine;

define encode(n,l) -> string;
    vars i,string='';
    fast_for i from 2 to l+1 do
        string ><
        if i > n then '0 '
        else '1 '
        endif; -> string;
    endfor;
enddefine;

;;; load coarse.p

define gen;
    vars d,kp,i,j,k,dev,filebase='ntt',headstring,ties;

    fopen(filebase><'.pat',"w") -> dev;

    fputstring(dev,'zero 1  0 0  0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ');

    '1 0 ' -> headstring;

    fast_for k from 2 to 9 do

        fast_for j from 2 to 9 do

            if j == k then 1 -> prob;
            else comp_prob(k*j) -> prob;
            endif;

1 -> prob;

            if j == k then
                ' 1  ' -> ties;
            else
                ' 0  ' -> ties;
            endif;

            fputstring(dev,'p'><k><'x'><j><' '><prob><' '><headstring><ties><(encode(k,8))><' '><(encode(j,8))><' '><(code(j*k)));

        endfast_for;

    endfast_for;

    fclose(dev);

enddefine;
gen();
