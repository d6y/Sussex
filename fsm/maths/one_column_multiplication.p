
define one_column_multiplication;

    multiplication_start_position();
    push_mark();
    up();
    compute_product();
    jump_answer_space();

    if tens() > 0 then
        left();
        write_tens();
        right();
    endif;

    write_units();
    done();

enddefine;
