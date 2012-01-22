define FAIL(reason);
    pr('\n!!WARNING!!  Operation failed\n');
    ppr(reason); nl(1);
'OPERATION-THAT-FAILED ='; enddefine;

vars

    BLANK = "-",
    RULE  = "=",

    ROW
    COLUMN

    UPPER_COLUMN
    LOWER_COLUMN

    ANSWER_ROW
    ANSWER_COLUMN

    RIGHT_MOST_COLUMN = 1,
    LOWER_ROW = 2,
    UPPER_ROW = 1,

    TOP_COLUMN,
    START_ROW,

    PAGE,
    OFF_PAGE = [],
    WAS_OFF_PAGE = [],

    accumulator

    mult_longest_column
    upper_number
    lower_number

    Task_flag
    Operation_flag
    Starting_operation_flag

    add_leftmost
    lasttopnumber
    blank_mark
    mark
    this_r
    this_c
    lastbottomnumber

    ;

;;; Number of digits in an integer
define intlength(n) /* -> length */ ;
    length(n><'');
enddefine;

;;; Subscriptor for integers. Reads digits right to left.
define subsint(n,p) /* -> digit */ ;
    vars s=''><n;
    s(intlength(n)-p+1)-48;
enddefine;


define units;
    subsint(accumulator,1);
enddefine;

define tens;
    if intlength(accumulator) = 1 then
        0;
    else
        subsint(accumulator,2);
    endif;
enddefine;

;;; See page 278
define upper_leftmost;
    if Operation_flag = "multiplication" then
        COLUMN = upper_number;
    else
        COLUMN = add_leftmost;
    endif;
enddefine;

define lower_leftmost;
    if Operation_flag = "multiplication" then
        COLUMN = lower_number;
    else
        COLUMN = add_leftmost;
    endif;
enddefine;


define leftmostcolumn;
    if Operation_flag = "multiplication" then
        ;;; For multiplication, the LEFTMOSTCOLUMN is true when
        ;;; we focus on the last of the numbers in the top column.
        ;;; It should be thought of as a flag indicating that
        ;;; the last column has been processed (hence it stays on
        ;;; while starting a new row).
        lasttopnumber = TOP_COLUMN;
    else
        COLUMN = add_leftmost;
    endif;
enddefine;

define adding;
    vars row,col, width;
    "addition" -> Operation_flag;
    if add_leftmost = undef then
        length(PAGE(1)) -> width;
        for col from 1 to width do
            for row from 7 to length(PAGE)-4 do
                if PAGE(row)(col) /= BLANK then
                    width-(col-1) -> add_leftmost;
                    quitloop;
                endif;
            endfor;
        quitunless(add_leftmost = undef);
        endfor;
        if add_leftmost = undef then
            mishap('ADDING: Couldn\'t find leftmost column',[]);
        endif;
    endif;
enddefine;

define multiplying; "multiplication" -> Operation_flag; enddefine;

define rightmostcolumn;
    COLUMN = 1;
enddefine;


define _read(r,c);
    vars scan;
    if (r < 1 or r > length(PAGE)) or ;;; off page top/bottom
        (c < 1 or c > length(PAGE(r))) then ;;; page left/right
        unless OFF_PAGE matches [== [^r ^c ?scan]==] then
            BLANK -> scan;
            [^r ^c ^BLANK] :: OFF_PAGE -> OFF_PAGE;
        endunless;
    else
        PAGE(r)(c) -> scan;
    endif;

    if scan = BLANK then
        true -> blank_mark;
    else
        false -> blank_mark;
        scan -> mark;
    endif;
enddefine;

define moveby(r,c); /* -> (this_r, this_c); */
    lvars width = length(PAGE(1))+1;
    ROW + r ->> ROW -> this_r;
    COLUMN + c ->> COLUMN -> this_c;
    _read(ROW,width-COLUMN);
enddefine;

define _write(r,c,m);
    vars scan;

    if (r < 1 or r > length(PAGE)) or ;;; off page top/bottom
        (c < 1 or c > length(PAGE(r))) then ;;; page left/right
        if OFF_PAGE matches [== [^r ^c ?scan]==] then
            delete([^r ^c ^scan],OFF_PAGE) -> OFF_PAGE;
            [^r ^c ^scan] :: WAS_OFF_PAGE -> WAS_OFF_PAGE;
        endif;
        [^r ^c ^m] :: OFF_PAGE -> OFF_PAGE;
    else
        m -> PAGE(r)(c);
    endif;
enddefine;


define writeat(r,c,Mark);
    lvars width = length(PAGE(1))+1;
    r ->> ROW -> this_r;
    c ->> COLUMN -> this_c;
    _write(ROW,width-COLUMN,Mark); ;;; Mark -> PAGE(ROW)(width-COLUMN);
    Mark -> mark;
enddefine;

define write(Mark);
    lvars width = length(PAGE(1))+1;
    _write(ROW,width-COLUMN,Mark);  ;;; Mark -> PAGE(ROW)(width-COLUMN);
    Mark -> mark;
enddefine;

define moveto(r,c) -> (this_r, this_c);
    lvars width = length(PAGE(1))+1;
    r ->> ROW -> this_r;
    c ->> COLUMN -> this_c;
    _read(ROW,width-COLUMN);
enddefine;

define set_problem(numbers) -> page;
    vars o;
    dest(numbers) -> numbers -> o;
    if o = "+" then
        set_addition(numbers) -> page;
    elseif o = "x" then
        set_multiplication(numbers(1),numbers(2)) -> page;
    else
        mishap('SET_PROBLEM: Unrecognized operation',[^o]);
    endif;
enddefine;


define set_multiplication(top_number,bottom_number) -> page;
    vars width top_length bottom_length row column longest_length;

    ;;; Estimate number of columns needed -width-
    intlength(top_number) -> top_length;
    intlength(bottom_number) -> bottom_length;
    top_length + bottom_length + 1 -> width;

    max(top_length, bottom_length) ->> longest_length -> mult_longest_column;

    top_length -> upper_number;
    bottom_length -> lower_number;

    top_length -> lasttopnumber;
    bottom_length -> lastbottomnumber;

    longest_length -> mult_leftmost;
    undef -> add_leftmost;
    ;;; Empty page
    [% fast_for row from 1 to bottom_length*2+10 do
        [% fast_for column from 1 to width do
                BLANK;
        endfast_for; %];
    endfast_for; %] -> page;

    ;;; Draw rule line under problem
    fast_for column from 1 to longest_length+1 do
        RULE ->> page(5)(width-(column-1));
              -> page(6)(width-(column-1));
    endfast_for;

    ;;; Insert digits on page
    fast_for column from 1 to top_length do
        subsint(top_number,column) -> page(1)(width-(column-1));
    endfast_for;

    fast_for column from 1 to bottom_length do
        subsint(bottom_number,column) -> page(3)(width-(column-1));
    endfast_for;

;;;pr('Product should be '><(top_number*bottom_number)); nl(1);

    "multiplication" ->> Operation_flag -> Starting_operation_flag;
    "multiplication" -> Task_flag;
    7 -> START_ROW;
enddefine;

define correct_solve(problem) -> (start, finish, seq);
    set_problem(problem) -> PAGE;
    copytree(PAGE)-> start;
    if hd(problem) = "x" then
        [% multiplication(); %] -> seq;
    elseif hd(problem) = "+" then
        [% addition(); %] -> seq;
    else
        mishap('SOLVE_PROBLEM: Unrecognized operations',problem);
    endif;
    copytree(PAGE) -> finish;
enddefine;


define set_addition(numbers) -> page;
vars i, sum=0, longest_length=0,width,page;

    for i in numbers do
        max(intlength(i),longest_length) -> longest_length;
    endfor;

   longest_length + 1 -> width;
   longest_length -> add_leftmost;

    ;;; Empty page
    [% fast_for row from 1 to length(numbers)*2+4 do
        [% fast_for column from 1 to width do
                BLANK;
        endfast_for; %];
    endfast_for; %] -> page;

    ;;; Draw rule line under problem
    fast_for column from 1 to width do
        RULE ->> page(length(numbers)*2+1)(column)
              -> page(length(numbers)*2+2)(column);
    endfast_for;

    ;;; Insert digits on page
    for row from 1 to length(numbers) do
        numbers(row) + sum -> sum;
        for column from 1 to intlength(numbers(row)) do
            subsint(numbers(row),column) -> page(row*2-1)(width-(column-1));
        endfor;
    endfor;

;;;pr('Sum should be '><sum); nl(1);

    "addition" ->> Operation_flag -> Starting_operation_flag;
    "addition" -> Task_flag;
    1 -> START_ROW;
enddefine;


define correctly_solve_problem(Prob) -> (PROBLEM_PAGE, PAGE, correct_seq);

    [WHO IS USING THIS PROCEDURE?!] =>
    [CORRECTLY SOLVED PROBLEM] =>

    set_problem(Prob) -> PAGE;
    copytree(PAGE) -> PROBLEM_PAGE;
    if Prob(1) = "+" then
        [% addition(); %] -> correct_seq;
    else
        [% multiplication(); %] -> correct_seq;
    endif;
enddefine;


define init_vars;
    false -> blank_mark;
    false -> BOTTOM_COLUMN;
    undef -> mark;
    -1 -> TOP_COLUMN;
    -1 -> COLUMN;
    0 -> accumulator;
    [] -> WAS_OFF_PAGE;
    [] -> OFF_PAGE;
    Starting_operation_flag -> Operation_flag;
enddefine;
