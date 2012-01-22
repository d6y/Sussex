uses rcg
uses rc_ps
;;;load ~/pop/pdp3/pdp3.p
uses rc_graphplot

vars n=0,dummy;

[undef undef 0.2 0.8] -> rcg_usr_reg;
define one_step(dummy,w);
0.05*w + n*(1-0.05) -> n;
logistic(n)-> d;
if d > 0.7 then undef; else d; endif;
enddefine;

2 ->> rc_linewidth -> rcg_pt_lw;

rc_postscript('~/papers/postscript/cascade.ps',procedure();
XpwSetFont(rc_window, '-adobe-helvetica-bold-r-normal--*-180-*-*-p-*-iso8859-1')=>
2 ->> rc_linewidth ->> rcg_pt_lw ->> rcg_ax_lw ->> rcg_mk_lw -> rcg_tk_lw;
0 -> n;
rc_graphplot(1,1,50,'Steps',one_step(%1.0%),' ') -> region;
0 -> n;

one_step(0,1.5) -> p;
rc_jumpto(1,p);
for i from 2 to 50 do
one_step(0,1.5) -> p;
quitif(p=undef);
rc_drawto(i,p);
endfor;


0 ->n;
one_step(0,-1) -> p;
rc_jumpto(1,p);
for i from 2 to 50 do
one_step(0,-1) -> p;
quitif(p=undef);
rc_drawto(i,p);
endfor;



rc_print_at(10,0.735,'w=1.5 t=16');
rc_print_at(30,0.735,'w=1.0 t=37');
rc_print_at(40,0.31,'w=-1');
rc_print_at(-4,0.83,'Activity');

LineOnOffDash -> rc_linestyle;
rc_jumpto(0,0.7); rc_drawto(50,0.7); rc_jumpby(-52.4,-0.01);
rc_print_here('0.7');

rc_jumpto(0,0.5); rc_jumpby(-2.4,-0.01);
rc_print_here('0.5');

LineSolid -> rc_linestyle;
endprocedure, [5.5 5.5 1.4 1.4], true);
