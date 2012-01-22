load testerrrt.p

vars bs, fff, th, nfile;

'eq-coar10-' -> nfile;

test_errrt(nfile,1,10,0.4,0.9,50) -> (E,R);
mean_matrix(E) -> fff;
count_errors(fff,false);
vars r = [% for i from 1 to 64 do
    mean([% for j from 1 to 10 do unless R(j)(i)=0 then R(j)(i) endunless; endfor; %]);
    endfor; %];
rt_cor(r);

pr('plot_list('); pr(r); pr(');\n\n');
