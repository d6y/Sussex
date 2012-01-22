uses sysio

vars smallest_digit, largest_digit, output_numbers, dev, i,j, ops,
    op, answer, first_digit, second_digit, pattern_name, op_number,
    op_stim, encode_op;


[+ - * /] -> ops;
[ '1 0 0 0' '0 1 0 0' '0 0 1 0' '0 0 0 1'] -> encode_op;

1 -> smallest_digit;
5 -> largest_digit;

[] -> output_numbers;
for i from smallest_digit to largest_digit do
    for j from smallest_digit to largest_digit do
    for op in ops do
    1.0*popval([^i ^op ^j]) -> answer;
    unless answer isin output_numbers then
        answer :: output_numbers -> output_numbers;
    endunless;
    endfor;
endfor;
endfor;

define encode_input(n) -> string;
    vars i;
    '' -> string;
    for i from smallest_digit to largest_digit do
        if n = i then
            string >< '1 ' -> string;
        else
            string >< '0 ' -> string;
        endif;
    endfor;
enddefine;


define encode_output(n) -> string;
    vars i, no_one=true;
    '' -> string;
    for i in output_numbers do
        if n = i then
            string >< '1 ' -> string;
            false->no_one;
        else
            string >< '0 ' -> string;
        endif;
    endfor;
if no_one then [NO 1 IN STIMULUS FOR ^n] => endif;
enddefine;

;;; WRITE PATTERNS TO FILE

fopen('arith.pat',"w") -> dev;
[+ -] -> ops;
for i from smallest_digit to largest_digit do
    encode_input(i) -> first_digit;

    for j from smallest_digit to largest_digit do
    encode_input(j) -> second_digit;

    for op_number from 1 to length(ops) do
    ops(op_number) -> op;
    encode_op(op_number) -> op_stim;

    'p'><i><op><j -> pattern_name;

    1.0*popval([^i ^op ^j]) -> answer;
    encode_output(answer) -> answer;

    fputstring(dev, pattern_name><' '><op_stim><'  '
        ><first_digit><' '><second_digit>< '   '><answer);

    endfor;

    endfor;
endfor;
fclose(dev);

[Number of outputs = ^(length(output_numbers))] =>
