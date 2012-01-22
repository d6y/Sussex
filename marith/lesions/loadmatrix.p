uses statlib
uses sysio
load product_ZERO.p
load latex_matrix.p
load threshold_errors.p

3000000 -> popmemlim;

datafile('~/marith/lesions/results/AB2.5.E') -> E1;
datafile('~/marith/lesions/results/DE0.01.E') -> E2;
datafile('~/marith/lesions/results/RE0.4.E') -> E3;
datafile('~/marith/lesions/results/RM1.E') -> E4;

ascii_performance(E3(3),'',100)

vars s = inits(1);
12 ->s(1);

vars x,y, x1,x2, y1,y2,error_rate, product, sum;

[% fast_for x from 0 to 9 do fast_for y from 0 to 9 do
        x*y; endfast_for; endfast_for; %] -> product;

[% fast_for x from 0 to 9 do fast_for y from 0 to 9 do
        x+y; endfast_for; endfast_for; %] -> sum;

vars thistime = 1;

for j from 1 to 20 do

;;;mean_matrix(E)->fff;
ascii_performance(E(j),'Relaxed eqaul reduction (value=1.75)',25) -> ermat;

[% fast_for x from 0 to 9 do
    fast_for y from 0 to 9 do
        ermat(x,y);
    endfast_for;
endfast_for; %] -> error_rate;

cor(error_rate, product);

if thistime=4 then
pr(s); 1 -> thistime;
else
thistime + 1 -> thistime;
endif;
endfor;
;;; enscript -2r -L69 -fCourier6 output.p


datafile('~/marith/lesions/TRIM4.E') -> E5;
datafile('~/marith/lesions/DEC4.E') -> E6;

E6(14) -> e;

latex_matrix(fff,' ');
sysobey('latex et');
sysobey('xdvi et &');



datafile('~/marith/lesions/RLXADD_481.75.meanE') ->fff;
datafile('~/marith/lesions/RLXADD_481.625.E') ->E;
datafile('~/marith/lesions/results/DEC_DEL0.25.E') -> E;
;;;E-> fff;
mean_matrix(E) -> fff;


ascii_performance(fff,'Dec & Unit deletion (value=0.25)',25*20) -> ermat;

[% fast_for x from 0 to 9 do
    fast_for y from 0 to 9 do
        ermat(x,y);
    endfast_for;
endfast_for; %] -> error_rate;
[Error rate / Product] =>
cor(error_rate, product);
[Error rate / Sum] =>
cor(error_rate, sum);
nl(1);

count_errors(fff,false,100*25*20);








[% for j from 1 to 20 do

;;;mean_matrix(E)->fff;
ascii_performance(E(j),'Relaxed eqaul reduction (value=1.75)',25) -> ermat;

mean([% fast_for x from 0 to 9 do
        ermat(0,x); ermat(x,0);
endfast_for; %]); ;;; -> pcz;

endfor;%] ==>
