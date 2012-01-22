
load product_ZERO.p
load threshold_errors.p

load c_errrt.p
load zero_rt_cor.p
;;; ved testerrrt.p


test_errrt('weights/01_norm30-',1,5,0.4,0.9,25) -> (E,R);

[% for i from 1 to 100 do R(1)(i); endfor; %] -> r;
plot_list(r);
rc_print_at(1,33,'01_norm30-1.wts');

1 -> c;
rc_graphplot(0,1,9,'', [%for i from 0 to 9 do
    for j from 0 to 9 do
    if i = 5 then r(c); endif;
    c+1->c;
    endfor;
endfor; %], '') -> region;



zero_rt_cor(r);
what_errors(E);
count_errors(E(1),false,25*100);
