load testerrrt.p

vars fff,root_file = '01_norm30';

0.1 -> mint;
0.3 -> maxt;

test_errrt(root_file><'-',1,20,mint,maxt,25) -> (E,R);

R -> datafile('./lesions/TH-'><mint><'-'><maxt><'.R');
E -> datafile('./lesions/TH-'><mint><'-'><maxt><'.E');
mean_matrix(E) -> fff;
fff -> datafile('./lesions/TH-'><mint><'-'><maxt><'.meanE');
count_errors(fff,false,20*25*100);
/*
vars r = [% for i from 1 to 100 do
    mean([% for j from 1 to 20 do unless R(j)(i)=0 then R(j)(i) endunless; endfor; %]);
    endfor; %];

zero_rt_cor(r);

pr('plot_list(');
pr(r);
pr(');\n\n');

[% for i from 2 to N_problems do problem_error_count(i); endfor; %] -> ped_list;
[Error rate and RT]=>
cor(ped_list,r);
*/
[Correlation of Omissions to PRODUCT] =>
vars i,j,prod;
[% for i from 0 to 9 do for j from 0 to 9 do i*j; endfor; endfor; %] -> prod;
[% for i from 2 to 101 do fff(i,1); endfor; %] -> om;
cor(om,prod);
[% for i from 0 to 9 do for j from 0 to 9 do i+j; endfor; endfor; %] -> prod;
[SUM correlation] =>
cor(om,prod);
nl(1);
om =>
nl(3);
