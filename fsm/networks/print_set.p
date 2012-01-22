

define print_set(list);
    lvars l,p,r,c,ncols,nrows,width;

    4 -> ncols;
    12 -> width;

    length(list) -> l;
    l/ncols -> nrows;
    if intof(nrows) = nrows then
        intof(nrows) -> nrows;
    else
        intof(nrows)+1 -> nrows;
    endif;

    for r from 1 to nrows do
        for c from 1 to ncols do
            (c-1)*nrows+r -> p;
            unless p > l then
                pr_field(p,3,false,' ');
                pr_field(list(p),width,false,' ');
            endunless;
        endfor;
        nl(1);
    endfor;

enddefine;
