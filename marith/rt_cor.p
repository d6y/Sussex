
vars table, data;
vars c_and_g, miller, aiken;
raw_read_rt('human/c&gA85') -> (tables,data);
flatten(data) -> c_and_g;
raw_read_rt('human/miller_adjx') -> (tables,data);
flatten(data) -> miller;
raw_read_rt('human/aikenx') -> (tables,data);
flatten(data) -> aiken;

vars g3a, g3b, g3c, g4,g5;
read_collapsed('human/grade3a') -> g3a;
read_collapsed('human/grade3b') -> g3b;
read_collapsed('human/grade3c') -> g3c;
read_collapsed('human/grade4') -> g4;
read_collapsed('human/grade5') -> g5;




define rt_cor(x);
    vars a,b,r,adult,name,x,t,df,p,y,q,w,grade;
    foreach [?adult ?name] in [[^c_and_g 'Campbell'] [^miller 'Miller']
            [^aiken 'Aiken']] do
        pearson_r(x,adult) -> r;
        t_test_r(r,64) -> (t,df);
        upper_t(t,df) -> p;
        pr_field(name,12, false, ' ');
        pr(' r = '); prnum(r,3,6);
        pr(' p = '); pr(p);
        nl(1);
    endforeach;

    define insert(q,w);
        x((w-1)+((q-2)*8));
    enddefine;

    vars y = [% for a from 2 to 9 do
                    for b from a to 9 do
                    if a==b then insert(a,b); else
                        (insert(a,b) + insert(b,a)) /2.0;
                    endif;
                    endfor;
                endfor; %];

    foreach [?grade ?name] in [[^g3a 'Grade 3a'] [^g3b 'Grade 3b']
            [^g3c 'Grade 3c'] [^g4 'Grade 4'] [^g5 'Grade 5']] do
        pearson_r(y,grade) -> r;
        t_test_r(r,36) -> (t,df);
        upper_t(t,df) -> p;
        pr_field(name,12,false,' ');
        pr(' r = '); prnum(r,3,6);
        pr(' p = '); pr(p);
        nl(1);
    endforeach;

enddefine;
