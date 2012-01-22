uses sysio;

define latex_branch(tree);
    vars tree,node,left,right;

    dest(tree) -> tree -> node;

    tree(1) -> left;
    tree(2) -> right;

    if islist(left) then
        if islist(right) then
            '[/'><node><';'><(latex_branch(left))
            ><','><(latex_branch(right))><'/]';
        else
            '[/'><node><';'><(latex_branch(left))
            ><','><right><'/]';
        endif;
    else
        if islist(right) then
            '[/'><node><';'><left ><','><(latex_branch(right))><'/]';
        else
            '[/'><node><';'><left><','><right><'/]';
        endif;

    endif;


enddefine;



define latex_tree(tree,outfile);
    lvars tree, dev = fopen(outfile,"w");

    fputstring(dev,'\\chomsky');
    fputstring(dev,latex_branch(tree));
    fputstring(dev,'\\endchomsky');
    fclose(dev);
enddefine;


vars tree=
 [+ [* [+ [+ x x ] [* [- 0.089180 -0.268689] [- [+ x x] -0.397293]]] x]
    [+ x [+ x x]]]
;
latex_tree(tree,'tree.tex');
