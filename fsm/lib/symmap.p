
define in_sym_map(word) -> symbol;

[   [ADD +] [MUL x]
    [uLF L] [lLF l] [RHT r]
    [RUL =] [SPC S] [NUM 9]
    [TEN T]
] --> [== [^word ?symbol] ==];

enddefine;

define decode_input(i) -> text;
    vars p;
    '' -> text;
    if isstring(i) then
        for p from 1 to length(input_bits) do
            if substring(p,1,i) = '1' then
                ;;; if text /= '' then text >< '+' -> text; endif;
                text >< (in_sym_map(input_bits(p)(1))) -> text;
            endif;
        endfor;

    else mishap('DECODE_INPUT: No converter for that datatype',[^i]);
    endif;
enddefine;

define fsm_map_inputs(m);
    vars i,s;
    fsm_inputs(m) -> i;
    [% for s in i do
            decode_input(s);
        endfor; %] -> fsm_inputs(m);
enddefine;

vars symmap = true;
