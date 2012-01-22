
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
load coarse.p

/*
"line"->rcg_pt_type;
samegraph();
rc_graphplot(0,1,81,'',comp_prob,'') -> region;

comp_prob(9*9) =>
 */

define gen;
    vars d,kp,i,j,k,dev,filebase='01_NORMnz',ties,prob;

        fopen(filebase><'.pat',"w") -> dev;

        fputstring(dev,'zero 1.0  0  0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0  1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0');

        fast_for k from 0 to 9 do
            fast_for j from 0 to 9 do

                if j = k then
                    ' 1  ' -> ties;
                else
                    ' 0  ' -> ties;
                endif;
' 0  ' -> ties;
            comp_freq(k,j) -> prob;
1.0 -> prob;

                fputstring(dev,'p'><k><'x'><j><'  '><prob><' '><ties><(encode(k,10))><' '><(encode(j,10))><' '><(code(j*k)));
            endfast_for;

        endfast_for;

        fclose(dev);

enddefine;

gen();
