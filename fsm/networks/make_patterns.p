load networks/print_set.p
/*


[!!!! WARNING !!!! WARNING !!!! WARNING !!!!] => done -> addition; repeat 4 times .vedscreenbell endrepeat; [ADDITION HAS BEEN SWITCHED OFF!!] =>


vars nhidden = -1   ;

incremental_training_files ([
[+ 1 1]
[+ 1 1 1]
[+ 11 11]
[+ 11 1]
[+ 1 9]
[+ 1 19]
[+ 100 100]
[+ 101 109]
[+ 101 99]
[+ 101 899]
[x 1 1]
[x 2 5]
[x 11 1]
[x 111 1]
[x 12 5]
[x 12 9]
[x 1 11]
[x 11 11]
[x 1 111]
[x 12 15]
[x 12 19]
[x 12 50]
[x 12 55]
[x 12 59]
[x 12 90]
[x 12 95]
[x 12 99]
[x 111 11]
[x 111 111]
],
'~/fsm/patterns/mult', '.pat', nhidden);


incremental_training_files ([
],
'~/fsm/patterns/m', '.pat', nhidden);



add_to_file( '~/fsm/patterns/m2-30.pat',
             [
             [x 10 10]
             ],
            '~/fsm/patterns/m3-30.pat',
             nhidden);


make_training_set([ [+ 1 1]
                    [x 3 2]
                  ],
            '~/fsm/patterns/a10-'><nhidden><'.pat',
            nhidden);

*/

define write_input_string(dev, string, first_time) -> line;
    vars i,cmd, la, las = '', ins = '', nin, zero_or_one;

    foreach [?la ?cmd] in input_bits do
        popval(cmd) -> zero_or_one;
        ins >< zero_or_one >< ' ' -> ins;
        if zero_or_one = 1 then
            las >< la -> las;
        else
            las >< '___' -> las;
        endif;
    endforeach;

    finsertstring(dev,las><' ');
    finsertstring(dev,ins><' ');
    las ><' '><ins><' ' -> line;

    /* WRITE HIDDEN RECURRENCE */
    if first_time then
        finsertstring(dev,'* ');
        line >< '* ' -> line;
    else
        finsertstring(dev,': ');
        line >< ': ' -> line;
    endif;
enddefine;

define write_output_string(cmd,aa) -> line;
    vars i;
    '' -> line;

if aa > 0 then
    for i from 1 to aa do   ;;; For Auto asociation
        finsertstring(dev,'-1 ');
        line >< '-1 ' -> line;
    endfor;
endif;

    for i from 1 to length(output_operations) do
        if output_operations(i)(2) = cmd then
            finsertstring(dev,'1 ');
            line >< '1 ' -> line;
        else
            finsertstring(dev,'0 ');
            line >< '0 ' -> line;
        endif;
    endfor;
    fnewline(dev);
enddefine;

vars lines_so_far;
define code_sequence(seq,PAGE,string,dev,nhid);
    init_vars();
    vars i, first_time=true, line;
    for i in seq do
        write_input_string(dev,string,first_time) -> line;
        if i = "mark_carry" then tens(); endif;
        popval([ ^i(); ]) ->;
;;;        line >< write_output_string(i,nhid+length(input_bits)) -> line;
        line >< write_output_string(i,-1) -> line;
        [^^lines_so_far ^line] -> lines_so_far;
        false -> first_time;
    endfor;
enddefine;

define make_training_set(probs,filename,nhid);
    vars k = 0, PAGE, ORIG_PAGE, dev, numbers, seq, total_length=0, op;
    fopen(filename,"w") -> dev;
    [% for numbers in probs do
            dest(numbers) -> numbers -> op;
            if op = "+" then
                set_addition(numbers) -> PAGE;
                copytree(PAGE) -> ORIG_PAGE;
                1 -> START_ROW; ;;; addition only
                [% addition(); %] -> seq;
            else
                set_multiplication(numbers(1),numbers(2)) -> PAGE;
                copytree(PAGE) -> ORIG_PAGE;
                [% multiplication(); %] -> seq;
            endif;
            PAGE ==>
            code_sequence(seq,ORIG_PAGE,'p'><k><'-',dev,nhid);
            k + 1 -> k;
            length(seq).dup + total_length -> total_length
        endfor;%] =>
    [^filename length ^total_length] =>
    fclose(dev);
enddefine;


define incremental_training_files(probs,filehead,filetail,nhid);
    vars k = 0, PAGE, ORIG_PAGE, dev, numbers, seq, total_length=0, op;

    vars lines_so_far = [];

    [% for numbers in probs do

            fopen(filehead><(k+1)><filetail,"w") -> dev;
            for line in lines_so_far do
                fputstring(dev,line);
            endfor;

            dest(numbers) -> numbers -> op;
            if op = "+" then
                set_addition(numbers) -> PAGE;
                copytree(PAGE) -> ORIG_PAGE;
                1 -> START_ROW; ;;; addition only
                [% addition(); %] -> seq;
            else
                set_multiplication(numbers(1),numbers(2)) -> PAGE;
                copytree(PAGE) -> ORIG_PAGE;
                [% multiplication(); %] -> seq;
            endif;
            PAGE ==>
            code_sequence(seq,ORIG_PAGE,'p'><k><'-',dev,nhid);
            k + 1 -> k;
            length(seq);
            fclose(dev);
        endfor;%] =>

print_set(probs);
enddefine;



define add_to_file(file1,probs,file2,nhid);
    vars k = 0, infile, PAGE, ORIG_PAGE, dev, numbers, seq, total_length=0, op;

    vars lines_so_far = [];

    fopen(file1,"r") -> infile;
    fopen(file2,"wc") -> dev;

    repeat
        fgetstring(infile) -> string;
    quitif(string = termin);
        fputstring(dev,string); k+1->k;
    endrepeat;
    fclose(infile);

    [^file1 ^k lines] =>

    for numbers in probs do
        dest(numbers) -> numbers -> op;
        if op = "+" then
            set_addition(numbers) -> PAGE;
            copytree(PAGE) -> ORIG_PAGE;
            1 -> START_ROW; ;;; addition only
            [% addition(); %] -> seq;
        else
            set_multiplication(numbers(1),numbers(2)) -> PAGE;
            copytree(PAGE) -> ORIG_PAGE;
            [% multiplication(); %] -> seq;
        endif;
        code_sequence(seq,ORIG_PAGE,'p'><k><'-',dev,nhid);
        k + length(seq) -> k;
    endfor;

    fclose(dev);
    [^file2 ^k lines] =>
enddefine;
