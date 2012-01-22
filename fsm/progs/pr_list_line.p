;;; Prints each sub list an a new line
define pr_list_line(list);
    lvars l,list;
    fast_for l in list do
        pr(l); nl(1);
    endfast_for;
enddefine;
