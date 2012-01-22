load testerrrt.p

vars bs, fff, th, nfile,lo,hi,ped_list;

'NORM10after05-' -> nfile;

for lo in [0.9] do

1.0 -> hi;

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

hi + 0.1 -> hi;

enduntil;

endfor;
