load programs.p
9 -> rcg_mk_no;
1 -> rcg_tk_no;

load ~/pop/pdp3/pdp3.p

;;; err.p look.p newlook.p rt.p damage.p


vars net = pdp3_getweights('~/marith/mathnet/mn10',
        '~/marith/mathnet/mn_prob10-3');
pats -> pdp3_performance(net,0.2) -> (tss,percentage,errors,pss);
[^(net.pdp3_wtsfile) 'tss=' ^tss ^percentage '%'] =>

vars pats = pdp3_getpatterns('~/marith/mathnet/mn_norm.pat',
    101, 25, 38, true);


vars net = pdp3_getweights('~/marith/networks/01_new12',
'~/marith/weights/01_norm30-1');
vars pats = pdp3_getpatterns('patterns/01_NORM',101,21,38,true);


vars net = pdp3_getweights('mathnet/networks/mn12',
        'mathnet/weights/mn_norm12-1.wts');

vars pats = pdp3_getpatterns('mathnet/mn_norm',101,25,38,true);



vars pats = pdp3_getpatterns('NORMAL',65,17,32,true);
vars pats = pdp3_getpatterns('01_NORM',101,21,38,true);

vars net = pdp3_getweights('new10','PROB10ec0_05-16');
vars net = pdp3_getweights('new10','PROB10ec0_05-2');

vars pats = pdp3_getpatterns('zo',101,21,38,true);



vars net = pdp3_getweights('new10','PROB10-1');
vars net = pdp3_getweights('new10','PROB10ec0_05-2');
vars net = pdp3_getweights('new10','PROB10ec0_01-2');
vars net = pdp3_getweights('new10','NORM10-1');
vars net = pdp3_getweights('new10','prob-coar10-1');

vars net = pdp3_getweights('new10',
    '/csuna/home/richardd/tmp/development/dev10-5680');


vars net = pdp3_getweights('zo10','zo10-3');

pats -> pdp3_performance(net,0.2) -> (tss,percentage,errors,pss);
[^(net.pdp3_wtsfile) 'tss=' ^tss ^percentage '%'] =>
pss=>

mean([% for i from 1 to 20 do
vars net = pdp3_getweights('new10','PROB10ec0_05-'><i);
pats -> pdp3_performance(net) -> (tss,percentage,errors,pss);
[^(net.pdp3_wtsfile) 'tss=' ^tss ^percentage '%'] =>
tss;
endfor;nl(3); [mean is] => %]) =>
-- PCA PLOTTING -------------------------------------------------------

load clx_paths.p
load rcg_gfile.p

clx_paths(net,pats);
sysobey('pca20 p?x?.clx');

uses rcg_mouse_getarea.p
XpwSetFont(rc_window,'helvr06') =>
"box" -> rcg_ax_type;
newgraph();
repeat
rcg_mouse_getarea() -> (a,b,c,d);
[% a; c; d; b;%]=>
[^a ^c ^d ^b] -> rcg_usr_reg;
rc_gfile('forUNITS7-1.pca');
endrepeat;
rcg_gfile('stie20-1.pca');

--- SEARCHING HIDEN LAYER

load bp_one_hidden.p

define istie(a,b);
    if a = b then 1; else 0; endif;
enddefine;

vars stims, targs, bpnet, tss=3000, var;
bp_one_hidden(10,64,'stie10-4',istie) -> (stims,targs,bpnet);

until tss < 0.001 do
stims, targs -> bp_learn(bpnet) -> (tss,var);
[tss = ^tss var = ^var] =>
enduntil;

load bp_show_outputs.p

bp_show_outputs(bpnet,stims,[%for a from 2 to 9 do for b from 2 to 9 do
    ''><a><'x'><b; endfor; endfor; %]);

bp_printweights(bpnet);
