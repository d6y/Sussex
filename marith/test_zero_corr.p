
uses rcg_statlib

define flatten(d);
    vars i;
    [% for i in d do
            last(i);
        endfor;%];
enddefine;


define test_zero_corr(file);
    vars tables, data,a,b,x,y,r,sx,sy,t,df,p;
    raw_read_rt('miller_adjxZERO.rt') -> (tables,data);
    flatten(data) -> y;
    raw_read_rt(file) -> (tables,data);
    flatten(data) -> x;
    rcg_scattergram(x,y) -> (a,b);
    pearson_r(x,y) -> (r,sx,sy);
    t_test_r(r,64) -> (t,df);
    upper_t(t,df) -> p;

    if isstring(file) then
        [^file correlates with MILLER r = ^r p = ^p] =>
    else
        [^(file.pdp3_wtsfile) correlates with ^adults r = ^r p = ^p] =>
    endif;
enddefine;
