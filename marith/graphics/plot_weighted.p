
XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-95-*-*-p-*-iso8859-1')->;

define plot_weighted(net,pats);
    vars a,b,h,stim,xm,targ,c,name,weighted,activity,x0,y0,yp,xgap,ygap;
    -200 -> x0;
    220 -> y0;
    11 -> xgap;
    11 -> ygap;
    xgap/50 -> xm;
    1 -> c;

    fast_for h from First_output_unit to Last_output_unit do
        product_list(c)><'' ->s;
        if length(s) = 1 then s>< ' ' -> s; endif;
        rc_print_at(x0+xgap*(2+h-First_hidden_unit)-2,y0,substring(2,1,s));
        rc_print_at(x0+xgap*(2+h-First_hidden_unit)-2,y0+9,substring(1,1,s));
        c+1->c;
    endfast_for;

    fast_for h from First_hidden_unit to Last_hidden_unit do
        ''><h -> s;
        rc_print_at(x0+xgap*(h-First_hidden_unit)-2,y0,substring(2,1,s));
        rc_print_at(x0+xgap*(h-First_hidden_unit)-2,y0+9,substring(1,1,s));
        c+1->c;
    endfast_for;


    1->c;
    fast_for a from First_multiplier to Last_multiplier do ;;;2 to 9 do
        fast_for b from First_multiplier to Last_multiplier do ;;; a to 9 do
            'p'><a><'x'><b -> name;
            pdp3_selectpattern(name,pats) ->  (stim, targ);
            stim -> pdp3_activate(net) -> activity;
            net.pdp3_netinput -> weighted;
;;;activity -> weighted;
            y0-ygap*(c+(a-First_multiplier)) -> yp;
            c+1->c;
            rc_print_at(x0-40,yp-ygap/2+2,a><'x'><b);
            fast_for h from First_hidden_unit to Last_hidden_unit do
                plt_hinton(x0+xgap*(h-First_hidden_unit),yp,xm*weighted(h));
            endfast_for;
            fast_for h from First_output_unit to Last_output_unit do
                plt_hinton(x0+xgap*(2+h-First_hidden_unit),yp,xm*weighted(h));
            endfast_for;
        endfast_for;
    endfast_for;
enddefine;
