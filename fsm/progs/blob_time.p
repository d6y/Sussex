uses rc_arrow;

define blob_time(pics, op);

    vars np = length(pics), blob, xmin, xmax, ymin, ymax, x, y;

    vars previous = [], points, saved_points, next_point, x2,
        y2, xy, d, min_dist;

    for n in [8 9 10 11 12 13] do ;;;from 1 to 7 do

        [% for blob in pics(n) do

                if blob.BLabel = op then

                    blob.Bxmin -> xmin;
                    blob.Bxmax -> xmax;
                    blob.Bymin -> ymin;
                    blob.Bymax -> ymax;

                    xmin + (xmax - xmin) -> x;
                    ymin + (ymin - ymax) -> y;
                    [^x ^y];

                endif;

            endfor; %] -> points;

        copytree(points) -> saved_points;

        if previous = [] then
            foreach [?x ?y] in points do
                rcg_plt_bullet(x,y);
                rc_print_at(x,y,''><n);
            endforeach;
        else
            until points == nil do
                fast_destpair(points) -> points -> xy;
                xy(1) -> x; xy(2) -> y;

                if previous == nil then
                    rcg_plt_bullet(x,y);
                    rc_print_at(x,y,''><n);
                else
                    9999 -> min_dist;
                    [] -> next_point;
                    foreach [?x2 ?y2] in previous do
                        distance(x,y,x2,y2) -> d;
                        if d < min_dist then
                            d -> min_dist;
                            [^x2 ^y2] -> next_point;
                        endif;
                    endforeach;
                    delete(next_point,previous) -> previous;
                    rc_arrow_line(next_point(1),next_point(2),x,y,0.5);
                    rcg_plt_bullet(x,y);
                    rc_print_at(x,y,''><n);
                endif;
            enduntil;
        endif;
        copytree(saved_points) -> previous;
        ;;;readline()->;reset_screen();
    endfor;
enddefine;



reset_screen();
blob_time(new_pictures,"DWN");
