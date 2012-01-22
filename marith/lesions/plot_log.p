uses statlib;

define plot_records(r,n);
vars i;
LineOnOffDash -> rc_linestyle;;

[%    rc_jumpto(r(1)(1),r(1)(n));


r(1)(n);
    for i from 2 to length(r) do
        rc_drawto(r(i)(1),r(i)(n));
        r(i)(n);
    endfor; %];
LineSolid -> rc_linestyle;
enddefine;


define plot_log(d,damage_type);

[] -> y_data;

d --> [== [^damage_type ?records] ==];

[% foreach [?x = ?y = = =] in records do
    x; y;
    y :: y_data -> y_data;
endforeach; %] -> first_plot;

rc_graphplot2(first_plot,' ',' ') -> region;

;;; 1 = x
;;; 2 = error%   3=op rate  4=om rate
;;; 5 = prod p   6 = sum p

plot_records(records,1) -> y2_data;
cor(y2_data,rev(y_data));


enddefine;

/*

rc_print_at(1.5,112-20,'Absolute damage');
rc_print_at(1.5,109-20,'Correlations between percentage errors');
rc_print_at(1.5,106-20,'and ommission errors (dashed) r=0.9265 p=0.0118');

rc_print_at(2.5,0.01,'Correlation between SUM/PRODUCT & #ommisions');
rc_print_at(2.5,0.0103,'Absolute damage');

[undef undef 0 0.01] -> rcg_usr_reg;
undef -> rcg_usr_reg;
rc_print_at(2,100,'Absolute damage: percentage of operand errors/damage');


plot_log(d,[UNIT DELETION]);
plot_log(d,[DESTROY]);
plot_log(d,[ABSOLUTE]);
plot_log(d,[RELATIVE]);


*/
