
vars output_operations = [

[SAD    add_start_position]
[SMU    multiplication_start_position]

[ZAC    zero_accumulator]
[ADD    add_mark_to_accumulator]
[MUL    compute_product]
[PSH    push_mark]

[UNI    write_units]
[TEN    write_tens]
[MKZ    mark_zero]
[MKC    mark_carry]
[RDC    read_carry]

[TNC    top_next_column]
[JAS    jump_answer_space]
[JTR    jump_top_row]

[NAR    next_answer_row]
[NBC    next_bottom_column]

[LFT    left]
[RHT    right]
[UP_    up]
[DWN    down]

[IAC    inc_answer_column]
[ITC    inc_top_column]

[RUL    draw_rule]
[DON    done]

];

vars input_bits = [
[ADD    [if Task_flag = "addition" then 1; else 0; endif;]    ]
[MUL    [if Task_flag = "multiplication" then 1; else 0; endif;] ]
;;;[ADD    [if Operation_flag = "addition" then 1; else 0; endif;]    ]
;;;[MUL    [if Operation_flag = "multiplication" then 1; else 0; endif;] ]
[TEN    [if tens() /=0  then 1; else 0; endif;]              ]
[SPC    [if blank_mark then 1; else 0; endif;]          ]
[RUL    [if mark = "=" and not(blank_mark) then 1; else 0; endif;]          ]
[NUM    [if strnumber(''><mark) and not(blank_mark) then 1; else 0; endif;]     ]
;;;[LFT    [if leftmostcolumn()  then 1; else 0; endif;]    ]
[uLF    [if upper_leftmost() then 1; else 0; endif;] ]
[lLF    [if lower_leftmost() then 1; else 0; endif;] ]
[RHT    [if rightmostcolumn()  then 1; else 0; endif;]   ]

];



define shorten(w) -> sw;
output_operations --> [== [?sw ^w] ==];
enddefine;


define shorten_seq(seq);
    vars w,sw;
    [% for w in seq do
            if output_operations matches [== [?sw ^w]==] then
                sw;
            else
                w;
            endif;
        endfor; %];
enddefine;

vars operations = true;
