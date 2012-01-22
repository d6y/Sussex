load ~/pop/pdp3/pdp3.p
uses rcg
uses statlib

vars pats = pdp3_getpatterns('patterns/NORMAL',65,17,32,true);
vars p1, p2, npats=pdp3_npats(pats);

vars nin = 17, nout=32;

vars r_in_thresh = 0.5578
vars r_out_thres = 0.4094;

vars Cin = newarray([1 ^npats 1 ^npats]);
vars Cout = newarray([1 ^npats 1 ^npats]);

/*
for p1 from 1 to npats do
pdp3_selectpattern(p1,pats) -> (stim1, targ1);
for p2 from 1 to npats do
pdp3_selectpattern(p2,pats) -> (stim2, targ2);
pearson_r(stim1, stim2) -> Cin(p1,p2);
pearson_r(targ1, targ2) -> Cout(p1,p2);
endfor;
endfor;
*/


"ddecimal" -> popdprecision;    ;;; double precision loading
uses vec_mat;

define vector_to_vec(v);
    lvars l = length(v);
    consfloatvec(explode(v),l);
enddefine;

vars
    stimV = newarray([2 ^npats]),
    targV = newarray([2 ^npats]),
    stimA = newarray([2 ^npats 2 ^npats]),
    targA = newarray([2 ^npats 2 ^npats]);

fast_for p1 from 2 to npats do
    pdp3_selectpattern(p1,pats) -> (stim1,targ1);
    vector_to_vec(stim1) -> stimV(p1);
    vector_to_vec(targ1) -> targV(p1);
endfast_for;

vars rad = 180/pi;

fast_for p1 from 2 to npats do
    stimV(p1) -> stim1;
    targV(p1) -> targ1;
    fast_for p2 from 2 to npats do
        rad * vec_angle(stim1, stimV(p2) ) -> stimA(p1,p2);
        rad * vec_angle(targ1, targV(p2) ) -> targA(p1,p2);
    endfast_for;
endfast_for;

;;; remember Cin(1,1) is for all_zero
targA(2,3)/90=>

vars sino = newarray([2 ^npats]);
vars outsum, insum;

[% for p1 from 2 to npats do
0 -> insum;
0 -> outsum;
for p2 from 2 to npats do
unless p1 = p2 then
        outsum + (1-(targA(p1,p2)/90)) -> outsum;

        insum + stimA(p1,p2) -> insum;

endunless;
endfor;
max(1,outsum)->outsum;
insum / outsum -> sino(p1);

sino(p1);
endfor; %] -> s;


;;;rc_graphplot(2,1,65,'x',sino,'')->;

rcg_scattergram(r,s)=>
pearson_r(r,s) -> R;
;;;R=>
t_test_r(R,64) -> (t,df);
upper_t(t,df) -> p;
p=>

length(r) =>
plot_rt('tmp.rt');

vars l, c=2;
[% for x from 2 to 9 do
for y from 2 to 9 do
    [% sino(c); x; y; %];
c+1->c;
endfor;
endfor; %] -> l;

l=>
sort_by_n_num(l,1)==>
