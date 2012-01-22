load lesions/damagethem.p

vars fff,root_file = '01_norm30';

vars mint, maxt;
0.8 -> mint;
0.9 -> maxt;

test_errrt(root_file><'-',1,20,0.8,0.9,25,DT,DV) -> (E,R);

[% for i in E do
    newarray(boundslist(i), procedure(x,y); intof(i(x,y)); endprocedure);
endfor; %] -> cE;

copytree(cE) -> datafile('./lesions/'><DN><'.E');
mean_matrix(E) -> fff;
fff -> datafile('./lesions/'><DN><'.meanE');
count_errors(fff,false,20*25*100);

;;; zero_rt_cor(r);

;;;pr('plot_list(');
;;;pr(r);
;;;pr(');\n\n');

;;;[% for i from 2 to N_problems do problem_error_count(i); endfor; %] -> ped_list;
;;;[Error rate and RT]=>
;;;cor(ped_list,r);


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

[% for i in R do [% for j in i do intof(j); endfor %]; endfor; %] -> cR;

copytree(cR) -> datafile('./lesions/'><DN><'.R');
