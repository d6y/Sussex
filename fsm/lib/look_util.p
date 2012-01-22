
3 -> pdp3_printweights_rowspace;

define naming(unit,net) -> label;
    vars i, out1 = pdp3_firstoutputunit(net), nin = pdp3_nin(net);
    if unit < nin then ;;; input layer
        [% for i in input_bits do i(1); endfor;
            repeat (nin-length(input_bits)) times 'c'; endrepeat;
        %] (1+unit) -> label;
    elseif unit < out1 then ;;; hidden
        unit -> label;
    else ;;; output
        [% for i in output_operations do i(1); endfor; %](1+unit-out1) -> label;
    endif;
enddefine;

define netcheck(net,pats)->ps;
vars pc,er,ps,tss;
    0 -> pdp3_mu(net);
    0.95 -> pdp3_tmax(net);
    ;;; pats -> pdp3_performance(net,0.49) -> (tss,pc,er,ps);
    pats -> pdp3_performance(net,"largest") -> (tss,pc,er,ps);
    [^(sys_fname_nam(pdp3_wtsfile(net))) Tss ^tss , ^pc per cent] =>
enddefine;

vars look_util = true;
