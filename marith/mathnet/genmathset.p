uses sysio
load product_ZERO.p
load mathnet/mathnetrep.p
load siegler.p

define gen;
    vars d,kp,i,j,k,dev,filebase='mathnet/mn_norm',ties,prob;

    fopen(filebase><'.pat',"w") -> dev;

    fputstring(dev,'zero 1.0  0  0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0');

    fast_for k from 0 to 9 do
        fast_for j from 0 to 9 do

            if k == j then 1 -> ties; else 0 -> ties; endif;
            comp_freq(j,k) -> prob;
            1 -> prob;
            fputstring(dev,'p'><k><'x'><j><'  '><prob><' '><
                ties>< ' ' ><
                (mathnet_input(k)) ><'  ' ><
                (mathnet_input(j)) ><' '><(code(j*k)));
        endfast_for;

    endfast_for;

    fclose(dev);

enddefine;

sgen();
