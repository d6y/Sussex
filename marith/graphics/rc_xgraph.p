/*
uses rcg;
uses rc_ps;
uses statlib
load rcg_utils_hack.p
*/

define datapoint(a1,a2,l);
    l(1+(a2-2)+((a1-2)*8));
enddefine;

datafile('~/marith/results/reaction_times/PROB05.RT') -> R;
datafile('~/marith/results/reaction_times/NORM05.RT') -> R2;

;;;datafile('~/marith/results/reaction_times/PROB2.RT_LIST') -> R;
;;;datafile('~/marith/results/reaction_times/NORM2.RT_LIST') -> R2;

vars List1=R, List2=R2;

vars human = [743.688 788.188 827.375 785.813 846.875 838.813 887.063 888.563];
[% for i in human do i/1000.0; endfor; %] -> human;

vars GRADE5 = [1.47125 1.90625 1.92 1.7425 1.9825 2.06625 2.19125 2.0275];

define mean_sd(RTlist) -> (Data,sd_list);

    vars a,b,rt,list, Data;

    [] -> M;
    [] -> S;

    newarray([0 7], procedure(n); []; endprocedure) -> Data;

    vars rt = [%
            for i from 1 to 64 do
            mean([% for j from 1 to 20 do
                    unless RTlist(j)(i)=0 then RTlist(j)(i) endunless;
                    endfor; %]);
            endfor;
            %];

vars sd_list = [];

vars Data = [%
        fast_for a from 2 to 9 do
        [% fast_for b from 2 to 9 do
            unless a = b then
;;;                (datapoint(a,b,rt) + datapoint(b,a,rt))/2;
                datapoint(a,b,rt);
                datapoint(b,a,rt);
            else
                datapoint(a,b,rt);
            endunless;
        endfast_for; %] -> list;

mean(list);
[^^sd_list ^(SD(list))] -> sd_list;
endfast_for; %];

enddefine;

vars rcg_plt_sdbar_width = 0.15;
1 -> rcg_pt_cs;

define bars(x,y,one_sd);
    ;;; Plots a MARK_PROC at (x,y) and adds deviation bars of
    ;;; ONE_SD above and bellow
    lvars height = one_sd;
    lvars x,y;
    vars rad = 0.01;
    vars xrad = rad*(0.5/xs);

    rc_jumpto(x,y-height);     ;;; strut of the SD marker
    rc_drawto(x,y+height);

    rc_jumpto(x-rcg_plt_sdbar_width,y-height);       ;;; ornaments
    rc_drawto(x+rcg_plt_sdbar_width,y-height);
    rc_jumpto(x-rcg_plt_sdbar_width,y+height);
    rc_drawto(x+rcg_plt_sdbar_width,y+height);


    rc_draw_arc(x-xrad/2,y+rad/2,xrad,rad,0,360*64);

enddefine;

vars xs = 0.0255;

define justplot(list);
    vars a;
    for a from 1 to 8 do
        if a = 1 then
            rc_jumpto(2,list(a));
        else
            rc_drawto(a+1,list(a));
        endif;
    endfor;
enddefine;

define drawgraph(M,S);
    vars a;
    for a from 2 to 9 do
        if a == 2 then
            rc_jumpto(2,xs*M(1));
        else
            rc_drawto(a,xs*M(a-1));
        endif;

;;;        bars(a,xs*M(a-1),xs*S(a-1));
        rc_jumpto(a,xs*M(a-1));
    endfor;
enddefine;

;;;rc_postscript('~/papers/postscript/xrt.ps', procedure();

newgraph();
rc_start();
[undef undef 0.57 0.92] -> rcg_usr_reg;
[% for i in GRADE5 do i/2.52; endfor; %] -> GRADE5;
XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-180-*-*-p-*-iso8859-1')->;


LineOnOffDash -> rcg_pt_ls;


rc_graphplot({2 3 4 5 6 7 8 9}, ' ', GRADE5, ' ') -> region;
LineSolid -> rcg_pt_ls;

justplot(human);
8 -> rcg_pt_cs;
for i from 2 to 9 do
    rcg_plt_bullet2(i,human(i-1));
endfor;
rc_print_at(1,0.93,'RT (sec)');

;;;;;;;;;;;;;;
;;;LineOnOffDash -> rc_linestyle;
mean_sd(List1) -> (M,S);
for i from 2 to 9 do
    rcg_plt_cross(i,(M(i-1))*xs);
endfor;
drawgraph(M,S);

;;;;;;;;;;;;;;
;;;LineDoubleDash -> rc_linestyle;
mean_sd(List2) -> (M,S);
drawgraph(M,S);

;;;;;;;;;;;;;;;;;;

vars y = 0.66, y0=0.021,x0=6.1;
rc_print_at(x0,y,'Skewed');
rc_print_at(x0,y-y0,'Equalized');

rc_print_at(x0,y-y0-y0,'Grade 5');
rc_print_at(x0,y-y0-y0-y0,'Adult');


y+0.007 -> y;
vars x1=4.9, x2=5.9;

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

rc_print_at(5.5,0.53,'Table');

;;;endprocedure, [5 5 0.5 0.5], true);
