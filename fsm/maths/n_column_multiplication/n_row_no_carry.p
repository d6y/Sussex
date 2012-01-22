define multiply_n_row_no_carry; multiplying();

    multiplication_start_position();

    repeat

        push_mark();

        repeat

            jump_top_row();
            compute_product();

            jump_answer_space();
            write_units();

        quitif(lasttopnumber = TOP_COLUMN);

            inc_answer_column();
            inc_top_column();

        endrepeat;

    quitif(leftmostcolumn());

        next_answer_row();

        repeat BOTTOM_COLUMN times
            mark_zero();
        endrepeat;

        next_bottom_column();

    endrepeat;

    draw_rule();

    addition();

enddefine;
