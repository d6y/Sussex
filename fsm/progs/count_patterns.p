/*
sysobey('cd ~/fsm/patterns; wc -l mult[1-9].pat mult1[0-9].pat '
    ><' mult2[0-9].pat > FOO');

*/

uses sysio;

vars count = ffile('~/fsm/patterns/FOO');

vars size, lines, i, prev = 0;

for i from 1 to 29 do
    count(i)(1) -> lines;
    lines - prev -> size;
    lines -> prev;
    [pattern ^i contains ^size lines] =>
endfor;
