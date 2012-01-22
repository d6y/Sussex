uses sysio;
uses rcg;
load progs/colmap.p
load progs/video_title.p

datafile('~/pic350.lst') -> pictures;

vars new_pictures;
rev(pictures) -> new_pictures;

[% for line in new_pictures do
;;;    rev([% foreach [?x ?y ?l] in line do
;;;        [% x; y; l; %]; endforeach;
rev(line);
;;;    %]);
endfor; %] -> new_pictures;


350 ->> rc_window_xsize -> rc_window_ysize;
rc_start();
"box" -> rcg_ax_type;
"cross" -> rcg_pt_type;
[-2 0.5 -0.5 2] -> rcg_usr_reg;
[-0.4 2.2 -1.2 1.7] -> rcg_usr_reg;
;;; false -> rcg_usr_reg;
10 -> rcg_pt_cs;

reset_screen();
GXor->rc_linefunction;
plot_points2(new_pictures(70));
black()->;
rc_print_at(-1.5,1.5,'346-70.wts');



vars data = ffile('~/hid346.pca'), x, y;
[% foreach [?x ?y] in data do [% x; y; %]; endforeach; %] -> data;
rc_graphplot2(data,' ',' ')->region;

load progs/make_video_procs.p
"DWN" -> ColOut1; "ADD" -> ColOut2;

;;; DRAW THEM!



black()->;
rc_start();

title_screen([ 'Sequence 346' 'Start: 303a-19.wts' 'Training: mult20.pat'
'Autowrite: 15 epochs']);

[PRESS RETURN TO CONTINUE] =>
readline()==>

countdown(3);

title_screen([% Col1><' = '><ColOut1;  Col2><' = '><ColOut2%]);

[PRESS RETURN TO CONTINUE] =>
readline()==>


;;; show_blob_colourmap();
normal_font();
reset_screen();
[hit return] =>
readline()->;
vars draw_proc;

sys_real_time() -> now;

vars count = 0, file;

fast_for picture in new_pictures do

    reset_screen();

    GXor->rc_linefunction;
    draw_proc(picture);

    black()->;
    rc_print_at(1.5,-2.8,''><count);
    count + 1 -> count;
    count =>
    'col'><(leadzero(count))><'.mif' -> file;

sysobey('import -window Xgraphic '><file);
;;;readline()->;
endfast_for;

[DONE] =>
readline()->;
