
vars llx, lly, urx, ury, width, height;
region(1) -> llx;
region(2) -> urx;
region(3) -> lly;
region(4) -> ury;
urx-llx->width;
lly-ury->height;

vars PCA1 = 0, PCA2 = 1;

vars i, file_identifiers;

vars ColOut1, ColOut2, Col1, Col2;
'red' -> Col2;
'green' -> Col1;
"DWN" -> ColOut1; "JAS" -> ColOut2;
"NAR" -> ColOut1; "DON" -> ColOut2;
"DWN" -> ColOut1; "ADD" -> ColOut2;


define plot_points2(xyl);
    vars x,y,l,c=1;

    foreach [?x ?y ?l] in xyl do

        if length(l) = 4 then
            XpwSetColor(rc_window,'black')->;
            if c /= 1 then
                rc_drawto(x,y);
                rc_print_here(' '><c);
            else
                rc_jumpto(x,y);
                rc_print_here(' '><c);
            endif;
            c+1->c;
        else
            if l = ColOut1 then
                XpwSetColor(rc_window,Col1)->;
            elseif l = ColOut2 then
                XpwSetColor(rc_window,Col2)->;
            else
                XpwSetColor(rc_window,'cyan')->;
            endif;
        endif;
        rcg_plt_bullet(x,y);
    endforeach;
enddefine;



vars now, picture, black, white, wipe_screen, axis, draw_proc;


plot_points2 -> draw_proc;
XpwFillRectangle(%rc_window, rc_transxyout(llx,ury),
        rc_transxyout(width,height)%) -> wipe_screen;

rcg_def_ax(%llx,urx,' ',lly,ury,' '%) -> axis;
XpwSetColor(%rc_window,'white'%)->white;
XpwSetColor(%rc_window,'black'%)->black;

define constant procedure reset_screen;
    GXcopy->rc_linefunction;
    white()->;
    wipe_screen();
    black()->;
    axis();
enddefine;

define leadzero(n) -> s;
    n><'' -> s;
    while length(s) < 3 do
        '0'><s -> s;
    endwhile;
enddefine;
