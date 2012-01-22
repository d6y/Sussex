
define no_carry_no_gaps; adding();

    zero_accumulator();
    add_start_position();

    repeat;

        while mark /= RULE do

            if blank_mark then
                mishap('NO_CARRY_NO_GAPS: Blank in problem',
                    [row ^ROW column ^COLUMN]);
            endif;

            add_mark_to_accumulator();
            down();
        endwhile;

        down();
        write_units();

        if tens() /= 0 then
            mishap('NO_CARRY_NO_GAPS: Carry needed',[^accumulator]);
        endif;

    quitif(leftmostcolumn());

        zero_accumulator();
        top_next_column();

    endrepeat;

    done();

enddefine;
