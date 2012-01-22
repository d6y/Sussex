vars slides = false;
/*

Takes a MATRIX produce by threshold_errors.p and produces
a LaTeX table: emat.tex

*/

define TeXify(x,y,matrix,dev);

    vars Err, product, c, pattern = 2 +
        ((x-First_multiplier)*N_tables) + (y-First_multiplier),
        correct = x*y;

    finsertstring(dev,'$'><x><'\\times'><y><'$&');

    fast_for product from 2 to N_products do

        matrix(pattern,product) -> c;

        product_list(product) -> Err;


        if c = 0 then
            ' ' -> c;

        else

            if slides then
                if cross(x,y,Err,2) then
                    'x' -> c;
                elseif sametable(x,y,Err) then
                    'o' -> c;
                elseif x+y = Err then
                    '+' -> c;
                else '-' -> c;
                endif;

            else
                if c = 0 then
                    '' -> c;
                elseif c = true then
                    '+' -> c;
                elseif c = false then
                    '-' -> c;
                else
                    ''><intof(c) -> c;
                endif;

            endif;
        endif;

        if product_list(product) = correct then
            'c' -> c;
        endif;

        finsertstring(dev,c);

        unless product = N_products then
            finsertstring(dev,'&');
        else
            fputstring(dev,'\\\\');
        endunless;

    endfast_for;

enddefine;


define latex_matrix(matrix,name);
    lvars a,b,dev=fopen('emat.tex',"w");

    fputstring(dev,'\\begin{table}');
    finsertstring(dev,'\\tiny\\bf\\tabcolsep=');
    if N_products < 38 then
        fputstring(dev,'2pt');
    else
        fputstring(dev,'1.5pt');
    endif;

    fputstring(dev,'\\begin{tabular}{l');
    '' -> b;
    for a from 2 to N_products do
        finsertstring(dev,'r');
        b >< '&'><product_list(a) -> b;
    endfor;
    fputstring(dev,'}');
    fputstring(dev,b><'\\\\');

    fast_for a from First_multiplier to Last_multiplier do
        fast_for b from a to Last_multiplier do
            TeXify(a,b,matrix,dev);
            unless a==b then
                TeXify(b,a,matrix,dev);
            endunless;
        endfast_for;
    endfast_for;

    fputstring(dev,'\\end{tabular}');
    fputstring(dev,'\\caption{Network error matrix: '><name><'}');
    fputstring(dev,'\\label{neterr}');
    fputstring(dev,'\\end{table}');
    fclose(dev);
enddefine;



define latex_performance(matrix,name,TRIALS);
    lvars a,b,dev=fopen('emat.tex',"w"),esum,pattern;

    finsertstring(dev,'\\begin{table}\\begin{center}\\begin{tabular}{c|');
    '\\multicolumn{1}{c}{Operand}' -> b;
    for a from First_multiplier to Last_multiplier do
        finsertstring(dev,'c');
        b >< '& ' >< a -> b;
    endfor;
    fputstring(dev,'}');
    fputstring(dev,'\\multicolumn{1}{c}{First}&\\multicolumn{'><(N_tables)><'}{c}{Second Operand}\\\\');
    fputstring(dev,b><'\\\\\\cline{2-'><(N_tables+1)><'}');

    fast_for a from First_multiplier to Last_multiplier do

    finsertstring(dev,a><'');

        fast_for b from First_multiplier to Last_multiplier do

        2 + ((b-First_multiplier)*N_tables) +
            (a-First_multiplier) -> pattern;

        0 -> esum;
        fast_for o from 2 to N_products do
            matrix(pattern,o) + esum -> esum;
        endfast_for;

        min(round(100*esum/TRIALS), 100) -> epc;

        finsertstring(dev,'&'>< epc );

        endfast_for;  fputstring(dev,'\\\\');
    endfast_for;

    fputstring(dev,'\\end{tabular}\\end{center}');
    fputstring(dev,'\\caption{Error percentages for: '><name><'}');
    fputstring(dev,'\\label{neterr}');
    fputstring(dev,'\\end{table}');
    fclose(dev);
enddefine;

define ascii_performance(matrix,name,TRIALS) -> ermat;
    lvars a,b,esum,pattern, WIDTH = 4;
    vars er,oe,ode,om, epc;

    newarray([^First_multiplier ^Last_multiplier
        ^First_multiplier ^Last_multiplier]) -> ermat;

    count_errors(matrix,false,TRIALS,true) --> [?oe ?ode ?om ?er];

    pr('\n\nError percentages: '><name); nl(2);

    pr_field(' ',WIDTH,false,' '); pr('  ');
    for a from First_multiplier to Last_multiplier do
    prnum(a,WIDTH,0);
    endfor; nl(1);

    pr_field(' ',WIDTH,false,' '); pr(' +');
    for a from First_multiplier to Last_multiplier do
    pr_field('-',WIDTH,'-',false);
    endfor; nl(1);

    fast_for a from First_multiplier to Last_multiplier do

    prnum(a,WIDTH,0); pr(' |');

        fast_for b from First_multiplier to Last_multiplier do

        2 + ((b-First_multiplier)*N_tables) +
            (a-First_multiplier) -> pattern;

        0 -> esum;
        /* INCLUDING OMISSION ERRORS */
        fast_for o from 1 to N_products do
            matrix(pattern,o) + esum -> esum;
        endfast_for;


    min(round(100*esum/TRIALS), 100) -> epc;
    epc -> ermat(a,b);

    prnum(epc,WIDTH,0);


        endfast_for;

if a = First_multiplier then
    pr('   Operand: '); prnum(oe,3,3);
elseif a = First_multiplier+1 then
    pr('  Close op: '); prnum(ode,3,3);
elseif a = First_multiplier+2 then
    pr('  Omission: '); prnum(om,3,3);
endif;
nl(1);
    endfast_for;

enddefine;
