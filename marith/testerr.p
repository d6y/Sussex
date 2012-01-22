
load programs.p
load c_errrt.p
load threshold_errors.p
load plot_list.p

vars net = pdp3_getweights('new10','prob-coar10-1');
vars pats = pdp3_getpatterns('NORMAL',65,17,32,true);

vars e,r,o;
errrt(net, pats, 2, 65, 0.0, 100, 0.05, 0.0, 0) -> (e,r,o);

plot_list(r);
rt_cor(r); nl(1);
r=>

latex_matrix(e,'');
matrix =>
count_errors(e,false);
pr_matrix(e);
/*
Total of 164 errors (tokens), of which...
Operand distance effect    75.00  45.73%
Operand errors            151.00  92.07%
  ...of which two prob      0.00   0.00%
Table unrelated (close)     1.00   0.61%
Table unreated (distant)   12.00   7.32%
Operation errors            0.00   0.00%
*/
