uses rcg;

define listar(blist,list);
    newarray(blist,procedure j k;
        list.hd; list.tl-> list
    endprocedure);
enddefine;

vars mmmult;

define mkrotate(rx,ry,rz) -> R;
    lvars Rx,Ry,Rz,R;
    listar([1 3 1 3],[% 1,0,0,0,cos(rx),-sin(rx),0,sin(rx),cos(rx) %]) -> Rx;
    listar([1 3 1 3],[% cos(ry),0,sin(ry),0,1,0,-sin(ry),0,cos(ry) %]) -> Ry;
    listar([1 3 1 3],[% cos(rz),-sin(rz),0,sin(rz),cos(rz),0,0,0,1 %]) -> Rz;
    mmmult(mmmult(Rx,Ry),Rz) -> R
enddefine;

define mmmult(A,B) -> C;
    vars ma na mb nb sum i j k;
    boundslist(A).dl -> na -> -> ma ->;
    boundslist(B).dl -> nb -> -> mb ->;
    if na /= mb then
        mishap('Matrices non-conformable for multiplication',[^A ^B])
    endif;
    newarray([1 ^ma 1 ^nb]) -> C;
    for i from 1 to ma do
        for j from 1 to nb do
            0 -> sum;
            for k from 1 to na do
                A(i,k) * B(k,j) + sum -> sum;
            endfor;
            sum -> C(i,j)
        endfor
    endfor
enddefine;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vars rc_3d_xscale, rc_3d_yscale, rc_3d_zscale;
vars rc_3d_R;
vars rc_3d_perspective = false;



define rc_3d_to_2d(x,y,z) -> (x,y);
vars i, xyz;
    x*rc_3d_xscale->x;
    y*rc_3d_yscale->y;
    z*rc_3d_zscale->z;
    newarray([1 3 1 1]) -> xyz;
    x -> xyz(1,1);
    y -> xyz(2,1);
    z -> xyz(3,1);
    mmmult(rc_3d_R,xyz) -> xyz;
    xyz(1,1) -> x;
    xyz(2,1) -> y;
    xyz(3,1) + 2.5 -> z;
    unless z = 0 or (rc_3d_perspective =false) then
        rc_window_xsize * (x/z) -> x;
        rc_window_ysize * (y/z) -> y;
    else
        rc_window_xsize * x/2.5 -> x;
        rc_window_ysize * y/2.5 -> y;
    endunless;
enddefine;

define rc_3d_jumpto(x,y,z);
    rc_3d_to_2d(x,y,z) -> (x,y);
    rc_jumpto(x,y)
enddefine;

define rc_3d_drawto(x,y,z);
    rc_3d_to_2d(x,y,z) -> (x,y);
    rc_drawto(x,y)
enddefine;

define rc_3d_cross(x,y,z);
    rc_3d_to_2d(x,y,z) -> (x,y);
    rcg_plt_cross(x,y)
enddefine;


define rc_3d_print_at(x,y,z,txt);
    rc_3d_jumpto(x,y,z);
    rc_print_here(txt);
enddefine;


define rc_3d_unitcube;

    rc_3d_jumpto(0,0,0);
    rc_3d_drawto(0,1,0);
    rc_3d_drawto(1,1,0);
    rc_3d_drawto(1,0,0);
    rc_3d_drawto(0,0,0);

    rc_3d_jumpto(0,0,1);
    rc_3d_drawto(0,1,1);
    rc_3d_drawto(1,1,1);
    rc_3d_drawto(1,0,1);
    rc_3d_drawto(0,0,1);
    rc_3d_drawto(0,0,0);

    rc_3d_jumpto(0,1,0);
    rc_3d_drawto(0,1,1);

    rc_3d_jumpto(1,0,0);
    rc_3d_drawto(1,0,1);

    rc_3d_jumpto(1,1,0);
    rc_3d_drawto(1,1,1);
enddefine;

define rc_3d_home;
    mkrotate(-15,25,0) -> rc_3d_R;
enddefine;

define rc_3d_init;
 rc_start();
    rc_default();
    3 -> rcg_pt_cs;
    50 -> rc_xorigin;
    400 -> rc_yorigin;
    700 -> rc_window_xsize;
    700 -> rc_window_ysize;
    1 ->> rc_3d_xscale ->> rc_3d_yscale -> rc_3d_zscale;
enddefine;


define rc_3d_axis(s);
    lvars i, aw=0.05,n;
    for i from 0 by s to 1 do

        for n from 0 to 1 do

            rc_3d_jumpto(0,n,i);    ;;; z
            rc_3d_drawto(aw,n,i);

            rc_3d_jumpto(1,n,i);
            rc_3d_drawto(1-aw,n,i);

            rc_3d_jumpto(n,i,0);    ;;; y
            rc_3d_drawto(n,i,aw);

            rc_3d_jumpto(n,i,1);
            rc_3d_drawto(n,i,1-aw);

            rc_3d_jumpto(i,n,0);    ;;; x
            rc_3d_drawto(i,n,aw);

            rc_3d_jumpto(i,n,1);
            rc_3d_drawto(i,n,1-aw);
        endfor;

    endfor;
enddefine;

define rc_3d_scale_list(list) -> newlist;
    ;;; Expects list in [ [x y z] [x y z] ... ]format
    vars x,y,z;
    lvars x0,y0,z0,xscale,yscale,zscale;

    foreach [?x ?y ?z] in list do
        min(x0,x) -> x0;
        max(xscale,x) -> xscale;
        min(y0,y) -> y0;
        max(yscale,y) -> yscale;
        min(z0,z) -> z0;
        max(zscale,z) -> zscale;
    endforeach;

    1.0/(xscale-x0) -> xscale;
    1.0/(yscale-y0) -> yscale;
    1.0/(zscale-z0) -> zscale;

    [%
    foreach [?x ?y ?z] in list do
        xscale * (x-x0) -> x;
        yscale * (y-y0) -> y;
        zscale * (z-z0) -> z;
        [% x; y; z; %];
    endforeach;
    %] -> newlist;

enddefine;

define rc_3d_prescaled_graphplot(xyzlist);
    ;;; Plots assuming data has already been scaled

    vars x,y,z,plotproc;

    if isprocedure(xyzlist) then
        (xyzlist) -> (xyzlist,plotproc);
    else
        rc_3d_cross -> plotproc;
    endif;

    foreach [?x ?y ?z] in xyzlist do
        plotproc(x,y,z);
    endforeach;
enddefine;

define rc_3d_graphplot(xyzlist);
    vars plotproc;
    if isprocedure(xyzlist) then
        (xyzlist) -> (xyzlist,plotproc);
    else
        rc_3d_cross -> plotproc;
    endif;

    rc_3d_prescaled_graphplot(rc_3d_scale_list(xyzlist),plotproc);
enddefine;





rc_3d_home();

/*
rc_3d_init();
rc_3d_unitcube();
rc_3d_cross(0.5,0.5,0.5);
*/
