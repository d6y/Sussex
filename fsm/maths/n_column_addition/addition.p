

define addition; adding();
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

        unless rightmostcolumn() then
            read_carry();
            unless blank_mark then
                add_mark_to_accumulator();
            endunless;
        endunless;

        tens() -> carry;
        if carry /= 0 then
            if leftmostcolumn() then
                left();
                write_tens();
                right();
            else
                mark_carry(carry);
            endif;
        endif;

        write_units();


    quitif(leftmostcolumn());

        zero_accumulator();
        top_next_column();

    endrepeat;

    done();

enddefine;
