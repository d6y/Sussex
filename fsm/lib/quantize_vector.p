
;;; Quantize each bit [0,1] in vector to nstates-ary vector

define quantize_vector(vector, nstates) -> new_vector;
    lvars bit,i,inc=1.0/nstates,cut_off;
    {% for bit in vector using_subscriptor subscrv do
            inc -> cut_off;
            fast_for i from 1 to nstates do
                if bit < cut_off then
                    (i-1);
                    quitloop;
                else
                    cut_off + inc -> cut_off;
                endif;
            endfast_for;
        endfor; %} -> new_vector;
enddefine;
