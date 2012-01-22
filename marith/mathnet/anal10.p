load analprocs.p

test20('mn10','mn_prob10');
test20('mn10','mn_norm10');


uses rcg

datafile('mn_norm10.rt') -> rtp10;
zero_rt_cor(rtp10);

rc_print_at(1,30,'bp using mathnet input (10 hidden, norm)');
plot_list(rtp10);
