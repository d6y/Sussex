/*

VERTICALLY STACK A HORIZONTAL LIST

    vstack_hline(indent, hlist, width);

Each horizontal line (row) is indented with -indent- spaces.

Each vertical entry (column) is at most -width- characters wide.

The first (width-1) characters of each element in -hlist- is
printed on the first line, followed by a space.

The next line prints the following (width-1) characters, and so on
until all characters have been printed.

For example:

    vstack_hlist(5, [this could be the start of something big], 4);

Produces:

     thi cou be  the sta of  som big
     s   ld          rt      eth
                             ing



*/

define vstack_hlist(indent,hlist, width);
    lvars i, oversize=false, item_width = width-1;

    repeat indent times pr(' '); endrepeat;
    fast_for i in hlist do
        if length(i) fi_> item_width then
            true -> oversize;
            quitloop;
        endif;
    endfast_for;

    [% for i in hlist do
            i >< '' -> i;
            length(i) -> l;
            if l fi_> item_width then
                spr(substring(1,item_width,i));
                substring(width,l fi_- item_width,i);
            else
                pr_field(i,width,false,' ');
                '';
            endif;

        endfor; %] -> hlist; nl(1);

    if oversize then
        vstack_hlist(indent, hlist, width);
    endif;

enddefine;
