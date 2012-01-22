uses rc_fill_arc;
uses convex_hull;

define procedure distance(x1,y1,x2,y2) -> d;
    sqrt((x1-x2)**2 + (y1-y2)**2)->d;
enddefine;


defclass procedure blob_record {
    BLabel, ;;; Word
    BXys   ;;; List of x0 y0 x1 y1 lines
};


define procedure find_labels(xyl) -> label_list;
    [] -> label_list;
    vars l;
    until xyl == nil do
        fast_destpair(xyl) -> xyl -> l;
        l(3) -> l;
        unless l isin label_list then
            conspair(l,label_list) -> label_list;
        endunless;
    enduntil;
enddefine;


define find_blobs(xyl,threshold) -> blob_list;

    vars x,y, x2, y2, l, unq_lbs, xys, points, xy,
        blob_record, edge_points, blob_points, new_blob_points;

    [] -> blob_list;

    find_labels(xyl) -> unq_lbs;

    fast_for l in unq_lbs do

        ;;; Find all points with this label
        [% foreach [?x ?y ^l] in xyl do
                [^x ^y];
            endforeach; %] -> xys;

        until xys == nil do

            [] -> edge_points;
            fast_destpair(xys) -> xys -> xy;
            xy(1) -> x;
            xy(2) -> y;

            [[^x ^y]] -> blob_points;

            ;;; Find the others that are close to it

            foreach [?x2 ?y2] in xys do
                if distance(x,y,x2,y2) < threshold then
                    conspair([^x2 ^y2],blob_points) -> blob_points;
                    delete([^x2 ^y2],xys) -> xys;
                endif;
            endforeach;

            ;;; Remove duplicate points
            [] -> new_blob_points;
            until blob_points == nil do
                fast_destpair(blob_points) -> blob_points -> points;
                rc_transxyout(points(1),points(2)) -> y -> x;
                [^x ^y] -> points;
                unless member(points,new_blob_points) then
                    conspair(points,new_blob_points) -> new_blob_points;
                endunless;
            enduntil;

            if length(new_blob_points) == 1 then
                new_blob_points(1) -> lines;
            else
                convex_hull(new_blob_points) -> lines;
                flatten(rev(lines)) -> lines;
            endif;

            if lines == nil then
                new_blob_points(1) -> lines;
            endif;

            consblob_record(l,lines) -> blob_record;
            conspair(blob_record,blob_list) -> blob_list;

        enduntil;

    endfast_for;
enddefine;


define procedure show_blob_colourmap;
vars x,y,x2,y2, label, colour;
    GXcopy->rc_linefunction;
    for y from 1 to 2 do
        for x from 1 to 12 do
            colour_map(x+((y-1)*12)) --> [?label ?colour];
            XpwSetColor(rc_window,colour><'')->;
            region(1)+x/3->x2;
            0.6+region(4)-y/4->y2;
            rc_fill_rectangle(x2,y2+0.1,32,16);
            XpwSetColor(rc_window,'white')->;
            rc_jumpto(x2+0.01,y2-0.02);
            rc_print_here(label><'');
        endfor;
    endfor;
enddefine;

define procedure plot_blobs(blobs);

    lvars xys, npoints, label, edges, blob, colour;


    fast_for blob in blobs do

        blob.BXys -> xys;
        length(xys) -> npoints;
        blob.BLabel -> label;

        GXor -> rc_linefunction;
        colour_table(label) -> colour;
        XpwSetColor(rc_window,colour><'')->;

        if npoints == 2 then
            rcg_plt_square(xys(1),xys(2));
        else
            XpwFillPolygon(rc_window,xys,Convex,CoordModeOrigin);
            ;;;rc_fill_arc(xmin,ymax,(xmax-xmin),(ymin-ymax),0,360*64);
            ;;;XpwDrawLines(rc_window, xys, CoordModeOrigin);
        endif;
    endfast_for;

enddefine;

/*
vars b,p;
find_blobs(pictures(1),threshold) -> b;
b==>
sys_real_time()->now;
reset_screen();
plot_blobs(b);
sys_real_time()-now=>
*/
