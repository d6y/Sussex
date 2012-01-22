
;;; One of N encoding
define encode(n,l) -> string;
    vars i,string='';
    fast_for i from 2 to l+1 do
        string ><
        if i == n then '1 '
        else '0 '
        endif; -> string;
    endfor;
enddefine;

/*
;;; Thermometer encoding
define encode(n,l) -> string;
    vars i,string='';
    fast_for i from 2 to l+1 do
        string ><
        if i > n then '0 '
        else '1 '
        endif; -> string;
    endfor;
enddefine;
*/


define comp_prob(n);
((90-n)/88)*1.0;
enddefine;

/*
define comp_prob(n);
vars x = 133;
1.0* ( (x-n)/(x-4));
enddefine;
*/



;;; Coarse coding
load coarse.p

/*
"line"->rcg_pt_type
rc_graphplot(4,1,81,'',comp_prob,'') -> region;
comp_prob(81) =>
 */

define gen;
    vars d,kp,i,j,k,dev,filebase='prob',ties,prob;

        fopen(filebase><'.pat',"w") -> dev;

        fputstring(dev,'zero 1  0  0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0  1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0');

        fast_for k from 2 to 9 do
            fast_for j from 2 to 9 do

                if j == k then
                    ' 1  ' -> ties;
                else
                    ' 0  ' -> ties;
                endif;

comp_prob(j*k) -> prob;
;;;1 -> prob;
                fputstring(dev,'p'><k><'x'><j><'  '><prob><' '><ties><(encode(k,8))><' '><(encode(j,8))><' '><(code(j*k)));
            endfast_for;

        endfast_for;

        fclose(dev);

enddefine;

gen();
