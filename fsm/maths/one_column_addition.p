
define one_column_addition; adding();

    zero_accumulator();
    add_start_position();

    while mark /= RULE do
        add_mark_to_accumulator();
        down();
    endwhile;

    down();

    if tens() > 0 then
        left();
        write_tens();
        right();
    endif;

    write_units();
    done();

enddefine;
