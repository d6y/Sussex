
/* Given one "picture" from make_video, this procedure returns a list
   of blobs, [ [label [x y] [x y]...] [label [x y] [x y] ]... region x y x y]

The "region" defines the rectangle covering all the blob's points

*/

define find_blobs(xyl,threshold) -> blob_list;

    vars x,y, x2, y2, l, unq_lbs, xys, xmin, xmax, ymin, ymax, xy,
        blob_record, edge_points, blob_points, low_x, low_y, hi_x, hi_y;

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
            xy(1) ->> x ->> xmin -> xmax;
            xy(2) ->> y ->> ymin -> ymax;

            [[^x ^y]] -> blob_points;
            [^x ^y] ->> low_x ->> low_y ->> hi_x -> hi_y;

            ;;; Find the others that are close to it

            foreach [?x2 ?y2] in xys do
                if distance(x,y,x2,y2) < threshold then

                    if x2 < xmin then x2 -> xmin; [^x2 ^y2] -> low_x;
                    elseif x2 > xmax then x2 -> xmax; [^x2 ^y2] -> hi_x; endif;
                    if y2 < ymin then y2 -> ymin; [^x2 ^y2] -> low_y;
                    elseif y2 > ymax then y2 -> ymax; [^x2 ^y2] -> hi_y; endif;

                    conspair([^x2 ^y2],blob_points) -> blob_points;
                    delete([^x2 ^y2],xys) -> xys;
                endif;
            endforeach;

            conspair(low_x,edge_points) -> edge_points;
            conspair(hi_x,edge_points) -> edge_points;

            unless member(low_y,edge_points) then
                conspair(low_y,edge_points) -> edge_points;
            endunless;

            unless member(hi_y,edge_points) then
                conspair(hi_y,edge_points) -> edge_points;
            endunless;

            ;;; Tidy up...

            vars rcy, rcx, rcx2, rcy2,line, lines;
            []->lines;

            until edge_points == nil do
                fast_destpair(edge_points) -> edge_points -> xy;
                xy(1) -> x;
                xy(2) -> y;
                rc_transxyout(x,y) -> rcy -> rcx;
                foreach [?x2 ?y2] in blob_points do
                    unless x2==x and y2==y then
                        rc_transxyout(x2,y2) -> rcy2 -> rcx2;
                        [% rcx; rcy; rcx2; rcy2; %] -> line;
                        unless member([^rcx2 ^rcy2 ^rcx ^rcy],lines) or
                            member(line,lines) then
                            conspair(line,lines) -> lines;
                        endunless;
                    endunless;
                endforeach;
            enduntil;

            if lines == nil then
                blob_points(1) -> lines;
            endif;

            consblob_record(l,flatten(lines),xmin,xmax,ymin,ymax)
                -> blob_record;
            conspair(blob_record,blob_list) -> blob_list;

        enduntil;

    endfast_for;
enddefine;
