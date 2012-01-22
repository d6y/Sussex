
define code_input(first_time,nhid) -> (las, input);
vars nin, i, la, cmd, zero_or_one, las = '';

{%  foreach [?la ?cmd] in input_bits do
        popval(cmd) ->> zero_or_one;
        if zero_or_one = 1 then
            las >< la -> las;
        else
            las >< '___' -> las;
        endif;
    endforeach;

    ;;; hidden bits

    length(input_bits)-1 -> nin;
    if first_time then
        repeat nhid times 0; endrepeat;
    else
        for i from 1 to nhid do
        -(i+nin+nhid)
        endfor;
    endif;

    %} -> input;

enddefine;
