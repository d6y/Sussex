
define multiply_one_row_no_carry; multiplying();

    multiplication_start_position();
    push_mark();

    repeat

        jump_top_row();
        compute_product();

        jump_answer_space();
        write_units();

    quitif(leftmostcolumn());

        inc_answer_column();
        inc_top_column();

    endrepeat;

    done();

enddefine;
