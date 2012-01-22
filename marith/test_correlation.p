uses rcg_statlib

define flatten(d);
    vars i;
    [% for i in d do
            last(i);
        endfor;%];
enddefine;


define test_correlation(file);
    vars adults, tables, data,a,b,x,y,r,sx,sy,t,df,p;

for adults in [% 'c&gA85'; 'miller_adjx'; 'aikenx'; %] do

    raw_read_rt(adults) -> (tables,data);
    flatten(data) -> y;
    raw_read_rt(file) -> (tables,data);
    flatten(data) -> x;
    rcg_scattergram(x,y) -> (a,b);
    pearson_r(x,y) -> (r,sx,sy);
    t_test_r(r,64) -> (t,df);
    upper_t(t,df) -> p;

    if isstring(file) then
        [^file correlates with ^adults r = ^r p = ^p] =>
    else
        [^(file.pdp3_wtsfile) correlates with ^adults r = ^r p = ^p] =>
    endif;
endfor;
enddefine;




define test_ped_correlation(file);
    vars tables, data,a,b,x,y,r,sx,sy,t,df,p;
    raw_read_rt(file) -> (tables,data);
    flatten(data) -> y;
    raw_read_rt('ped.dat') -> (tables,data);
    flatten(data) -> x;
    rcg_scattergram(x,y) -> (a,b);
    pearson_r(x,y) -> (r,sx,sy);
    t_test_r(r,64) -> (t,df);
    upper_t(t,df) -> p;

    if isstring(file) then
        [^file correlates with PED data r = ^r p = ^p] =>
    else
        [^(file.pdp3_wtsfile) correlates with PED data r = ^r p = ^p] =>
    endif;

enddefine;



define box_net(file);
    raw_read_rt(file) -> (tables,data);
    flatten(data) -> x;
    if isstring(file) then
        rcg_boxplot(x,file);
    else
        rcg_boxplot(x,file.pdp3_wtsfile);
    endif;
enddefine;

define graph_net(file);
    raw_read_rt(file) -> (tables,data);
    flatten(data) -> x;
    freq_list(x) -> x;
    rc_graphplot2(x,'RT','freq');
enddefine;

/*
test_correlation('thru10-1');
rcg_boxplot(x,'');
plot_rt('tiesrp20-5') =>
plot_rt('c&gA85') =>

 */
