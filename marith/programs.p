
uses statlib;
uses sysio;
uses stringtolist;
vars region;
uses rcg;

vars threshold;
load ~/pop/pdp3/pdp3.p

load product_ZERO.p
;;;load product_code.p
load response_mechanism.p
load read_rt.p
;;; load check.p

load cascade_rt.p
load graphics/plot_rt.p
;;; load genmean.p
load trace_reaction.p
load graphics/plot_zrt.p
;;; load genmeanz.p
;;; load find_threshold.p
;;; load plot_outputs.p
load test_correlation.p
vars time_limit = 50;
vars threshold = 800;
load graphics/plot_list.p
