define multiply_one_row_carry; multiplying();
    lvars carry;

    multiplication_start_position();
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

    done();

    if carry /= 0 then
        pr('Warning: Carry remains lowered in leftmost column\n');
    endif;

enddefine;
