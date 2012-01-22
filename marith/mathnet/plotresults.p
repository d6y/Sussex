uses rcg;
uses statlib;

load ../product_ZERO.p
load ../threshold_errors.p
load ../graphics/plot_list.p

vars E = datafile('mn_prob12.meanE');
vars R = datafile('mn_prob12.rt');


plot_list(R);
rc_print_at(2,32,'MATHNET skew 12 hidden');
