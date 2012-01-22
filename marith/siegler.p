/* Number of times each problem presented in second- and
   third-grade workbooks. [Sigler Strategy ... multiplication p.268] */

vars siegler_raw = [
    [4  3  2  4  4  1  5  1  3  4]
    [2  3  2  3  4  3  5  7  5  2]
    [1  3 19 18 17 20 18 17 17 20]
    [2  3 18 24 17 19 15 15 15 13]
    [3  1 19 20 19 20 14 11  2 17]
    [3  2  9 15 18 21 13 14 11 14]
    [2  4  6 10 12 12 13 14 11  6]
    [4  2  6  7  6  9  8  8  7  9]
    [1  3  6  6  6  7  8  7  6  6]
    [2  1  5 11  6  7  8  9  7  7] ];

/* Convert to relative frequencies */

vars sum = 0,  table, number;
for table in siegler_raw do
    for number in table do
    ;;;number + sum -> sum;
    max(number,sum) -> sum;
    endfor;
endfor;

/* Index by (1st multipler, 2nd multiplier) */
vars comp_freq = newarray([0 9 0 9]);
vars x,y;
for x from 0 to 9 do
    for y from 0 to 9 do
        1.0 * (siegler_raw(x+1)(y+1) / sum) -> comp_freq(x,y);
    endfor;
endfor;

;;;pr_array(comp_freq);

/*
for a from 0 to 9 do
pr(a);
for b from 0 to 9 do
pr('&');pr(siegler_raw(a+1)(b+1));
endfor;
pr('\\\\\n');
endfor;
*/

[% for a from 2 to 9 do
[% a; 1.0/mean([%
for b from 0 to 9 do
siegler_raw(a+1)(b+1);
unless a==b then
    siegler_raw(b+1)(a+1)
endunless;
endfor;
%]); %];
endfor; %] -> xy;

rc_graphplot2(xy,'','')->region;
