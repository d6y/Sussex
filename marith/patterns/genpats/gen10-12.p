uses sysio
/*
 * ;;; One of N encoding
 * define encode(n,l) -> string;
 *     vars i,string='';
 *     fast_for i from 2 to l+1 do
 *         string ><
 *         if i == n then '1 '
 *         else '0 '
 *         endif; -> string;
 *     endfor;
 * enddefine;
 *
 * define comp_prob(n) -> p;
 * vars n;
 * ((90-n)/90)*1.0 -> p;
 * enddefine;
*/

;;; Siegler probabilities
load siegler.p

;;; Coarse coding
;;;load coarse.p
load inrep12.p

/*
"line"->rcg_pt_type;
samegraph();
rc_graphplot(0,1,81,'',comp_prob,'') -> region;

comp_prob(9*9) =>
 */

define zeros(n) -> s;
    '' -> s;
    repeat n times
        s ><'0 ' -> s;
    endrepeat;
enddefine;

define gen;
    vars d,kp,i,j,k,dev,filebase='12_NORM',ties,prob;

        fopen(filebase><'.pat',"w") -> dev;

        fputstring(dev,'zero 1.0  0 '><(zeros(15))>< ' '><(zeros(15)) ><
            '  1 '>< (zeros(N_products-1)) );

        fast_for k from 0 to 12 do
            fast_for j from 0 to 12 do

                if j = k then
                    ' 1  ' -> ties;
                else
                    ' 0  ' -> ties;
                endif;

if k > 9 or j > 9 then
    1.0* ((180-(k*j))/360) -> prob;
else
    comp_freq(k,j) -> prob;
endif;

1.0 -> prob;
fputstring(dev,'p'><k><'x'><j><'  '><prob><' '><ties
    ><(mathnet_input(k))><
    ' '><(mathnet_input(j))
    ><' '><(code(j*k)));
            endfast_for;

        endfast_for;

        fclose(dev);

enddefine;

gen();
