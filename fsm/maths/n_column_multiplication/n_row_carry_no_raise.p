
define multiply_n_row_carry_no_raise; multiplying();
lvars carry;

    multiplication_start_position();

    repeat

        push_mark();

        repeat

            jump_top_row();
            compute_product();

            jump_answer_space();

            unless rightmostcolumn() then
                read_carry();
                unless blank_mark then
                    add_mark_to_accumulator();
                endunless;
            endunless;

            tens() -> carry;
            if carry /= 0 then
                mark_carry(carry);
            endif;

            write_units();

        quitif(leftmostcolumn());

            inc_answer_column();
            inc_top_column();

        endrepeat;

    quitif(lastbottomnumber = BOTTOM_COLUMN);

        next_answer_row();

        repeat BOTTOM_COLUMN times
            mark_zero();
        endrepeat;

        next_bottom_column();

    endrepeat;

    draw_rule();

    addition();

enddefine;
