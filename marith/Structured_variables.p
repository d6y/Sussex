vars sv_sum = [% for a from First_multiplier to Last_multiplier do
                    for b from First_multiplier to Last_multiplier do
                        a+b; endfor; endfor; %];

vars sv_prod = [% for a from First_multiplier to Last_multiplier do
                    for b from First_multiplier to Last_multiplier do
                        a*b; endfor; endfor; %];

vars sv_min = [% for a from First_multiplier to Last_multiplier do
                    for b from First_multiplier to Last_multiplier do
                        min(a,b); endfor; endfor; %];

vars sv_max = [% for a from First_multiplier to Last_multiplier do
                    for b from First_multiplier to Last_multiplier do
                        max(a,b); endfor; endfor; %];


define structured_variables(r);
nl(1);
pr('Correlations to structure variables\n');

pr('Sum     '); cor(sv_sum,r);
pr('Product '); cor(sv_prod,r);
pr('Min     '); cor(sv_min,r);
pr('Max     '); cor(sv_max,r);
pr('Sum     '); cor(sv_sum,r);
enddefine;
