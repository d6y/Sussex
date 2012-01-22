

define sort_by_n_alpha(list,n);
    syssort(list, procedure(i1, i2); alphabefore(i1(n),i2(n)); endprocedure);
enddefine;

define sort_by_n_num(list,n);
    syssort(list, procedure(i1, i2); i1(n)<i2(n); endprocedure);
enddefine;

define sort_by_head_alpha(list);
    sort_by_n_alpha(list,1);
enddefine;

define sort_by_head_num(list);
    sort_by_n_num(list,1);
enddefine;
