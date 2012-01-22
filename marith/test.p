uses rcg
uses statlib
;;;load product_10-12.p
load product_code.p
load graphics/plot_list.p
load Structured_variables.p
load ~/pop/pdp3/pdp3.p
load read_rt.p
load rt_cor.p
rc_print_at(5,17,'0-12 tables, 20 equalized nets');

vars r = [21.9 25.3 25.5556 23.8 31.5 25.7 29.4 27.4 25.2 26.3333 29.1111
     23.875 25.3 28.3333 24.8889 23.1 25.6667 29.9 21.8 25.5 26.2222
     28.8889 25.4444 29.1 23.7 23.875 25.7 21.5 22.0 27.4 29.5556 25.8889
     31.6 25.4 26.2222 21.8889 24.1 23.3 27.375 26.8 26.0 28.5556 29.0
     27.3 23.2 24.7 24.0 25.6 29.3 24.8889 25.6667 29.4444 27.375 24.0
     24.0 25.4444 27.1 23.2 29.3 25.0 26.5 25.5 25.3333 21.3];

rt_cor(r);

structured_variables(r);

rc_print_at(3,26.8,'Mean RT 10 no-skew networks');
