
load ~/fsm/maths/n_column_multiplication/one_row_carry_raise.p
load ~/fsm/maths/n_column_multiplication/n_row_carry_raise.p

define multiplication;
    if PAGE(3)(length(PAGE(3))-1) = BLANK then
        multiply_one_row_carry_raise();
    else
        multiply_n_row_carry_raise();
    endif;
enddefine;
