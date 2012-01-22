define no_carry_gaps; adding();

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
        write_units();

    quitif(leftmostcolumn());

        zero_accumulator();
        top_next_column();

    endrepeat;

    done();

enddefine;
