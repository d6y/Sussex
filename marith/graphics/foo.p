/*
uses rcg;
uses rc_ps;
uses statlib
load rcg_utils_hack.p
*/

define datapoint(a1,a2,l);
    l(1+(a2-2)+((a1-2)*8));
enddefine;


vars human = [743.688 788.188 827.375 785.813 846.875 838.813 887.063 888.563];
[% for i in human do i/1000.0; endfor; %] -> human;

vars GRADE5 = [1.47125 1.90625 1.92 1.7425 1.9825 2.06625 2.19125 2.0275];

define mean_sd(RTlist) -> (Data,sd_list);

    vars a,b,rt,list, Data;

    [] -> M;
    [] -> S;

    newarray([0 7], procedure(n); []; endprocedure) -> Data;


vars rt = [% for i from 1 to 64 do
    mean([% for j from 1 to 20 do unless RTlist(j)(i)=0 then RTlist(j)(i) endunless; endfor; %]);
    endfor; %];
vars sd_list = [];

    vars Data = [%
            fast_for a from 2 to 9 do
            [% fast_for b from 2 to 9 do
                unless a = b then
                    (datapoint(a,b,rt) +datapoint(b,a,rt))/2;
                else
                    datapoint(a,b,rt);
;;;                    (datapoint(a,b,rt)) :: ties -> ties;
                endunless;
                endfast_for; %] -> list;
                mean(list);
                [^^sd_list ^(SD(list))] -> sd_list;
            endfast_for; %];

enddefine;

vars rcg_plt_sdbar_width = 0.15;
1 -> rcg_pt_cs;

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

rc_postscript('~/papers/postscript/humanrt.ps', procedure();

newgraph();
rc_start();
[undef undef 0.7 1.2] -> rcg_usr_reg;
[% for i in GRADE5 do i*0.54 endfor; %] -> GRADE5;
XpwSetFont(rc_window, '-adobe-helvetica-medium-r-normal--*-180-*-*-p-*-iso8859-1')->;



rc_graphplot({2 3 4 5 6 7 8 9}, ' ', human, ' ') -> region;
LineSolid -> rcg_pt_ls;
rc_jumpto(9,0.7);
rc_drawto(10,0.7);

rc_jumpto(10,1.2);
rc_drawto(09.9,1.2);

rc_jumpto(10,1.2);
rc_drawto(10,0.7);


for i from 0.702+(0.54/5) by 0.54/5 to 1.2 do
i/0.54 -> yt;
rc_jumpto(9.9,i);
rc_drawto(10,i);
rc_print_at(10.2,i,''><yt);
endfor;

justplot(GRADE5);


rc_print_at(0.5,1.23,'RT (sec)');

rc_print_at(3,0.75,'Adult');
rc_print_at(5.6,1.16,'Grade 5');

;;;rc_print_at(x0,y-y0-y0,'Grade 5');
;;;rc_print_at(x0,y-y0-y0-y0,'Adult');

rc_print_at(5.0,0.64,'Table');

endprocedure, [5 5 0.5 0.5], true);
