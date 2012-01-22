/*
uses rcg;
uses rc_ps;
load rcg_utils_hack.p
*/
vars miladj = [137.9 145.45 238.25 263.2 252.85 242.55 273.8 249.6 336.7 335.9];
vars har = [612.4 594.8 683.5 686.6 721.3 682.3 753.35 753.75 772.55 797.05 ];
vars hs = 0.8, hm=350;
[% for i in har do (i-hm)*hs; endfor; %] -> har;


vars skew = [
21.4955 33.7276 30.2365 29.0181
31.1662 28.8377 29.835 30.9958 32.1339 29.6941];

vars equa = [
17.7334 29.6138 29.1618 27.7504 29.4565
27.6225 28.0274 29.6742 29.9696 27.6227
];

1 -> rcg_pt_cs;


vars xs = 11;

define justplot(list);
    vars a;
    for a from 1 to 10 do
        if a = 1 then
            rc_jumpto(0,list(a));
        else
            LineOnOffDash -> rc_linestyle;
            rc_drawto(a-1,list(a));
        endif;
    endfor;
enddefine;

define drawgraph(M);
    vars a;
    for a from 0 to 9 do
        if a == 0 then
            rc_jumpto(0,xs*M(1));
        else
            rc_drawto(a,xs*M(a+1));
        endif;

        rc_jumpto(a,xs*M(a+1));
    endfor;
enddefine;

rc_postscript('~/papers/postscript/x01rt.ps', procedure();
newgraph();
rc_start();
[undef undef 125 385] -> rcg_usr_reg;
;;;undef -> rcg_usr_reg;
XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-240-*-*-p-*-iso8859-1')->;


rc_graphplot({0 1 2 3 4 5 6 7 8 9}, ' ', miladj, '  ') -> region;

8 -> rcg_pt_cs;
for a from 0 to 9 do rcg_plt_bullet2(a,miladj(a+1)); endfor;

LineOnOffDash -> rc_linestyle;
justplot(har);
LineSolid -> rc_linestyle;


drawgraph(skew);
for a from 0 to 9 do rcg_plt_cross(a,xs*skew(a+1)); endfor;

drawgraph(equa);

rc_jumpto(9,130);
rc_drawto(9,380);

for a from (130+45) by 28 to (385) do
    (a/hs)+hm -> v;
    rc_jumpto(9,a);
    rc_drawto(8.8,a);
    rc_print_at(9.2,a-3,''><intof(v));
endfor;


rc_print_at(-1,399,'RT (msec)');
rc_print_at(-1,385,'Miller et al.');

;;;rc_print_at(9,399,'RT (msec)');
rc_print_at(9,385,'Harley');

vars y = 200, y0=16,x0=5.5;
rc_print_at(x0,y,'Skewed');
rc_print_at(x0,y-y0,'Equalized');

rc_print_at(x0,y-y0-y0,'Harley');
rc_print_at(x0,y-y0-y0-y0,'Miller et al.');


y+4 -> y;
vars x1=4.3, x2=5.3;

rc_jumpto(x1,y); rc_drawto(x2,y);
for x from x1 by 0.5 to x2 do
    rcg_plt_cross(x,y);
endfor;

rc_jumpto(x1,y-y0); rc_drawto(x2,y-y0);

LineOnOffDash -> rc_linestyle;
rc_jumpto(x1,y-y0-y0); rc_drawto(x2,y-y0-y0);

LineSolid -> rc_linestyle;
y-y0-y0-y0 ->y;
rc_jumpto(x1,y); rc_drawto(x2,y);
for x from x1 by 0.5 to x2 do
    rcg_plt_bullet2(x,y);
endfor;

rc_print_at(4,97,'Table');

endprocedure, [5 5 0.5 0.5], true);
