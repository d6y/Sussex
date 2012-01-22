
define plot_fanin(net,scale);
    vars u,units={},fans;

    [% for u from First_hidden_unit to Last_hidden_unit do
            units<>{%u%} -> units;
            {%pdp3_biases(net)(u)%} <>  pdp3_fanin(net,u);
        endfor; %] -> fans;

    if N_products = 32 then
        rcg_hinton(fans,[BS TIE 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9],units,scale);
    else
        rcg_hinton(fans,[BS TIE 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9],units,scale);
    endif;

    rc_print_at(1,length(units)+1, 'Hinton plot for hidden unit FAN IN'
        ><': '><(pdp3_wtsfile(net)));
enddefine;


define plot_fanout(net,scale);
    vars units = {BIAS},u,fans;

    [% {% for u from First_output_unit to Last_output_unit do
                (pdp3_biases(net))(u);
            endfor; %};

        for u from First_hidden_unit to Last_hidden_unit do
            units<>{%u%} -> units;
            pdp3_fanout(net,u);
        endfor; %] -> fans;

    rcg_hinton(fans,product_list,units,scale);

    rc_print_at(1,length(units)+1, 'Hinton plot for hidden unit FAN OUT'
        ><': '><(pdp3_wtsfile(net)));
enddefine;

uses rcg_hinton

define draw_table_problems(x,y,xscale,yscale,w,u,wscale);
    lvars a,b;
    rc_print_at(x-2.8*xscale,y,''><u);
    1+u-First_hidden_unit -> u;
    fast_for a from First_multiplier to Last_multiplier do
    fast_for b from First_multiplier to Last_multiplier do
            plt_hinton(x+(a-First_multiplier)*xscale,
                y-(b-First_multiplier)*yscale,
                (w(2+(a-First_multiplier)*N_tables+
                    (b-First_multiplier))(u))*wscale);
        endfast_for;
    endfast_for;
enddefine;

define show_hidden_activity(V,xs,ys,ws,label);
vars num,x,y;
lvars h;
    rc_start();
    rc_print_at(-200-xs,200+ys,'Hidden activity: '><pdp3_adddot(label,false));
    fast_for h from First_hidden_unit to Last_hidden_unit do
        h-First_hidden_unit->num;
        num div 3 -> y;
        num mod 3 -> x;
        -200 + x*(xs*(N_tables+2)) -> x;
        200 - y*(ys*(N_tables+2)) -> y;
        draw_table_problems(x,y,xs,ys,V,h,ws);
    endfast_for;
enddefine;


define draw_table_out(x,y,xscale,yscale,net,u,wscale);
lvars a,b;
vars f = pdp3_fanout(net,u),p;
    rc_print_at(x-2*xscale,y,''><u);
    fast_for a from First_multiplier to Last_multiplier do
        fast_for b from First_multiplier to Last_multiplier  do
            prob2prod(a,b) -> p;
            plt_hinton(x+(a-First_multiplier)*xscale,
                y-(b-First_multiplier)*yscale, (f(p)*wscale));
        endfast_for;
    endfast_for;
enddefine;

define show_hidden_fanout(net,xs,ys,ws);
lvars h;
vars num,x,y;
    rc_start();
    rc_print_at(-210-xs,210+ys,'Hidden fan-out: '><pdp3_wtsfile(net));
    fast_for h from First_hidden_unit to Last_hidden_unit do
        h-First_hidden_unit->num;
        num div 3 -> y;
        num mod 3 -> x;
        -200 + x*(xs*(N_tables+2)) -> x;
        200 - y*(ys*(N_tables+2)) -> y;
        draw_table_out(x,y,xs,ys,net,h,ws);
    endfast_for;
enddefine;



define show_hidden_fanin(net,xs,ys,ws);
    lvars h,i;
    vars x,y,num;
    rc_start();
    - (xs*5) -> x;
    rc_print_at(-200-xs,200+1.5*ys,'Hidden fan-in: '><pdp3_wtsfile(net));
    fast_for h from First_hidden_unit to Last_hidden_unit do
        h-First_hidden_unit->num;
        200 - num*(ys*3) -> y;
        pdp3_fanin(net,h) -> f;
        fast_for i from First_multiplier to Last_multiplier do
            plt_hinton(x+(i-First_multiplier)*xs,y,ws*f(i-First_multiplier+1));
            plt_hinton(x+(i-First_multiplier)*xs,y+ys,ws*f(i+N_tables-First_multiplier+1));
        endfast_for;
        plt_hinton(x-xs,y+ys/2,f(1));
        rc_print_at(x-2*xs,y+ys/2,''><h);
    endfast_for;
enddefine;


define plt_hinton(x,y,v);
    abs(v) -> rcg_pt_cs;
if abs(v) > 1 then
    sign(v) -> v;
    ;;; possibly a politically-incorrect euro-imperialist hang-up
    if v = 1 then          ;;; white is +ve
        rcg_plt_square(x,y);
        elseif v = -1 then     ;;; black is -ve
rcg_plt_box2(x,y);
;;;        rcg_plt_box(x,y);
    else ;;; don't plot zero
    endif;
endif;
enddefine;



define Xshow_hidden_activity(V,xs,ys,ws,label);
vars num,x,y;
lvars h;
    rc_start();
;;;    rc_print_at(200-xs,ys,'Hidden activity: '><pdp3_adddot(label,false));
    fast_for h from First_hidden_unit to Last_hidden_unit do
        h-First_hidden_unit->num;
        num div 3 -> y;
        num mod 3 -> x;
        -200 + x*(xs*(N_tables+4)) -> x;
        100-y*(ys*(N_tables+2.5)) -> y;
        draw_table_problems(x,y,xs,ys,V,h,ws);
        rc_jumpto(x-10,y+10);
N_products        rc_draw_rectangle(xs*(N_tables+1),ys*(N_tables+1.2));
    endfast_for;
enddefine;


define Xweighted(net,pats,xs,ys,ws,ann);
vars num,x,y,a,b;
lvars h;
    rc_start();


if ann then
    rc_print_at(-200,150,'Weighted sum to hidden: '><pdp3_adddot(net,false));
endif;

fast_for a from First_multiplier to Last_multiplier do ;;;2 to 9 do
    fast_for b from First_multiplier to Last_multiplier do
            'p'><a><'x'><b -> name;
            pdp3_selectpattern(name,pats) ->  (stim, targ);
            stim -> pdp3_activate(net) -> activity;
            net.pdp3_netinput -> weighted;

    fast_for h from First_hidden_unit to Last_hidden_unit do
        h-First_hidden_unit->num;
        num div 3 -> y;
        num mod 3 -> x;
        -200 + x*(xs*(N_tables+4)) -> x;
        100-y*(ys*(N_tables+2.5)) -> y;
        plt_hinton(x+(a-First_multiplier)*xs,
            y-(b-First_multiplier)*ys
            ,weighted(h)*ws);
        rc_jumpto(x-10,y+10);
        rc_draw_rectangle(xs*(N_tables+1),ys*(N_tables+1.2));
        rc_print_at(x-32,y,''><h);
    endfast_for;

endfast_for;
endfast_for;
enddefine;
