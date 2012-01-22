
vars miller_rt,harley_rt;
raw_read_rt('~/marith/human/harley') -> (tables, data);
flatten(data) -> harley_rt;
vars miller_rt_unadj;
raw_read_rt('~/marith/human/miller_rawZERO') -> (tables,data);
flatten(data) -> miller_rt_unadj;

raw_read_rt('~/marith/human/miller_adjxZERO') -> (tables, data);
flatten(data) -> miller_rt;

;;; Remove the first few (originally 20) data points
;;; from a list

define rm_twenty(x) -> y;
vars i;
[% for i from 11 to 100 do
x(i);
endfor; %] -> y;
enddefine;

rm_twenty(miller_rt) -> miller_rt;
rm_twenty(miller_rt_unadj) -> miller_rt_unadj;
rm_twenty(harley_rt) -> harley_rt;

[Lengths ^(length(miller_rt)) ^(length(miller_rt_unadj))
^(length(harley_rt))]=>


define zero_rt_cor(x);
vars NumProds=length(x);
    vars r,adult,name,t,df,p;
    foreach [?adult ?name] in [ [^harley_rt 'Harley'] [^miller_rt 'Miller']
        [^miller_rt_unadj 'Miller (unadj)']] do
        pearson_r(x,adult) -> r;
        t_test_r(r,NumProds) -> (t,df);
        upper_t(t,df) -> p;
        pr_field(name,12, false, ' ');
        pr(' r = '); prnum(r,3,6);
        pr(' p = '); pr(p);
        nl(1);
    endforeach;
enddefine;

[Skewed nets]=>

vars x = datafile('~/marith/results/reaction_times/01_prob30.R');

vars m = [%
for i from 1 to 100 do
mean([%
for n from 1 to 20 do
x(n)(i)->v;
if v/=0.0 then v; endif;
endfor;
%]);
endfor;
%];

zero_rt_cor(rm_twenty(m));


[Equalized nets]=>

vars x = datafile('~/marith/results/reaction_times/01_norm30.R');

vars m = [%
for i from 1 to 100 do
mean([%
for n from 1 to 20 do
x(n)(i)->v;
if v/=0.0 then v; endif;
endfor;
%]);
endfor;
%];

zero_rt_cor(rm_twenty(m));
