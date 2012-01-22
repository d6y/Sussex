
define zero_accumulator;
    0 -> accumulator;
"zero_accumulator"; enddefine;

define add_start_position;
    ;;; Bug here because START_ROW is set externally when the problem is
    ;;; created.  When a multiplication problem is set, but the system
    ;;; starts with this procedure, the START_ROW will be correct for
    ;;; multiplication, not addition.
    moveto(START_ROW,1) -> (ROW, COLUMN);
"add_start_position"; enddefine;

define add_mark_to_accumulator;
    if mark = undef then
        FAIL('No mark has been read (ADD)');
    else
        if isnumber(mark) then
            accumulator + mark -> accumulator;
        else
            FAIL('Mark ('><mark><') is not a number (ADD)');
        endif;
    endif;
"add_mark_to_accumulator"; enddefine;

define write_units;
    if accumulator = undef then
        FAIL('Can\'t write empty accumulator (UNITS)');
    else
        write(accumulator mod 10);
    endif;
"write_units"; enddefine;

define write_tens;
    if accumulator = undef then
        FAIL('Can\'t write empty accumulator (TEN)');
    else
        write(accumulator div 10);
    endif;
"write_tens"; enddefine;

define done;  "done"; enddefine;

define top_next_column;
    moveto(START_ROW,COLUMN+1) -> (ROW, COLUMN);
"top_next_column"; enddefine;

define mark_carry(digit);
    lvars width = length(PAGE(1))+1;
    if ROW+1 > length(PAGE) or ROW+1 < 1 then
        FAIL('mark_carry off the top/bottom of the page!');
    else
        if (width-(COLUMN+1)) < 1 or (width-(COLUMN+1)) > length(PAGE(ROW+1)) then
            FAIL('mark_carry off side of page!');
        else
            digit -> PAGE(ROW+1)(width-(COLUMN+1));
        endif;
    endif;
"mark_carry"; enddefine;

define read_carry;
    lvars width = length(PAGE(1))+1;
    _read(ROW+1,width-COLUMN);
"read_carry"; enddefine;

define down;    moveby( 2, 0);  "down";  enddefine;
define left;    moveby( 0, 1);  "left";  enddefine;
define right;   moveby( 0,-1);  "right"; enddefine;

;;;; Below this line, procedures introduced for multiplication

define multiplication_start_position;
    moveto(3,1) -> (ROW,COLUMN);
    7 -> START_ROW;   ;;; for addition
    7 -> ANSWER_ROW;
    1 -> ANSWER_COLUMN;
    1 -> TOP_COLUMN;
    1 -> BOTTOM_COLUMN;
    1 -> TOP_ROW;   /* FIXED */
    3 -> BOTTOM_ROW;
    ;;; multiplying(); GOAL set by set_problem()
"multiplication_start_position"; enddefine;

define push_mark;
    if mark = undef then
       FAIL('No mark has been read (push_mark)');
    else
        mark -> register;
    endif;
"push_mark"; enddefine;

define compute_product;
    if register = undef then
        FAIL('Register hasn\'t been pushed');
    elseif mark = undef then
        FAIL('Nothing has been read (compute_product)');
    else
        register * mark -> accumulator;
    endif;
"compute_product"; enddefine;

define jump_answer_space;
    moveto(ANSWER_ROW, ANSWER_COLUMN) -> (ROW,COLUMN);
"jump_answer_space"; enddefine;

define up;      moveby(-2, 0);  "up";    enddefine;

define jump_top_row;
    moveto(TOP_ROW, TOP_COLUMN) -> (ROW, COLUMN);
"jump_top_row"; enddefine;

define inc_answer_column;
    ANSWER_COLUMN + 1 -> ANSWER_COLUMN;
"inc_answer_column"; enddefine;

define inc_top_column;
    TOP_COLUMN + 1 -> TOP_COLUMN;
"inc_top_column"; enddefine;

define next_answer_row;
    1 -> ANSWER_COLUMN;
    ANSWER_ROW + 2 -> ANSWER_ROW;
    moveto(ANSWER_ROW, ANSWER_COLUMN) -> (ROW, COLUMN);
"next_answer_row"; enddefine;

define mark_zero;
    write(0);
    ANSWER_COLUMN + 1 ->> ANSWER_COLUMN -> COLUMN;
"mark_zero"; enddefine;

define next_bottom_column;
    BOTTOM_COLUMN + 1 -> BOTTOM_COLUMN;
    moveto(BOTTOM_ROW, BOTTOM_COLUMN) -> (ROW, COLUMN);
    1 -> TOP_COLUMN;
"next_bottom_column"; enddefine;

define draw_rule;
    vars col;
    for col from 1 to length(PAGE(1))do
        if ANSWER_ROW+2 >= length(PAGE) then
            FAIL('trying to draw_rule off page');
            quitloop;
        endif;
        RULE -> PAGE(ANSWER_ROW+2)(col);
        RULE -> PAGE(ANSWER_ROW+3)(col);
    endfor;
    adding();   ;;; Set New GOAL
"draw_rule"; enddefine;
