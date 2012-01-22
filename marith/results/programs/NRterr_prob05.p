load testerrrt.p

vars bs, fff, th, nfile, lo, hi, ped_list;

'PROB10ec0_05-' -> nfile;

for lo in [0.6 0.7 0.8 0.9] do

lo + 0.1 -> hi;

until hi > 1.0 do

[lo ^lo hi ^hi range ^(hi-lo)]=>

test_errrt(nfile,1,20,lo,hi,25) -> (E,R);
mean_matrix(E) -> fff;
count_errors(fff,false,20*25*64);
vars r = [% for i from 1 to 64 do
    mean([% for j from 1 to 20 do unless R(j)(i)=0 then R(j)(i) endunless; endfor; %]);
    endfor; %];
rt_cor(r);

[% for i from 2 to 65 do problem_error_count(i); endfor; %] -> ped_list;
[Error rate and RT]=>
cor(ped_list,r);

pr('plot_list('); pr(r); pr(');\n\n');

;;;fff-> datafile('PROB05.mat');
;;;R -> datafile('PROB05.RT');
;;;r -> datafile('PROB05.r');

/*
datafile('PROB05.r') -> r;
datafile('PROB05.mat') -> fff;;
latex_matrix(fff,'PROB10 (50 blocks threshold 0.4-0.9)');
sysobey('latex et; dvi2ps et | lpr -Plwa');
count_errors(fff,false);
rcg_scattergram(ped_list,r) -> (c,m);
cor(ped_list,r);
datafile('PROB05.RT') -> R;
*/

hi + 0.1 -> hi;

enduntil;

endfor;
