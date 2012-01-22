
define two_digit_carry_and_gaps; adding();
    lvars carry;

    zero_accumulator();
    add_start_position();

    repeat;

        while mark /= RULE do
            unless blank_mark then
                add_mark_to_accumulator();
            endunless;
            down();
        endwhile;

        down();

        if not(rightmostcolumn()) then
            read_carry();
            unless blank_mark then
                add_mark_to_accumulator();
            endunless;
        endif;

        tens() -> carry;
        if carry /= 0 then
            mark_carry(carry);
        endif;

        write_units();

    quitif(leftmostcolumn());

        zero_accumulator();
        top_next_column();

    endrepeat;

    done();

    if carry /= 0 then
        pr('Warning: Carry remains lowered in leftmost column\n');
    endif;

enddefine;
