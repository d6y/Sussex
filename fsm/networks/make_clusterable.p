load networks/print_set.p

section;

define lvars write_input_string(dev);
    vars i,cmd, la, las = '', ins = '', nin, zero_or_one;

    foreach [?la ?cmd] in input_bits do
        popval(cmd) -> zero_or_one;
        las >< zero_or_one -> las;
        ins >< zero_or_one >< ' ' -> ins;
    endforeach;

    finsertstring(dev,ins><' ');
    finsertstring(dev, decode_input(las)><'-'><number);
    number + 1 -> number;
enddefine;

define lvars code_sequence(seq,PAGE,dev);
    init_vars();
    vars i, first_time=true, line;
    for i in seq do
        write_input_string(dev);
        if i = "mark_carry" then tens(); endif;
        popval([ ^i(); ]) ->;
        fnewline(dev);
    endfor;
enddefine;

define global clusterable_file(prob,filename);
    vars k = 0, PAGE, ORIG_PAGE, dev, numbers, seq, total_length=0, op;
    vars number = 1;

    fopen(filename,"w") -> dev;

    dest(prob) -> prob -> op;
    if op = "+" then
        set_addition(prob) -> PAGE;
        copytree(PAGE) -> ORIG_PAGE;
        1 -> START_ROW; ;;; addition only
        [% addition(); %] -> seq;
    else
        set_multiplication(prob(1),prob(2)) -> PAGE;
        copytree(PAGE) -> ORIG_PAGE;
        [% multiplication(); %] -> seq;
    endif;

    code_sequence(seq,ORIG_PAGE,dev);

    fclose(dev);
enddefine;

endsection;
