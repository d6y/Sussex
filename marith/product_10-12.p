
vars First_multiplier = 0;
vars Last_multiplier = 12;
vars N_tables = (Last_multiplier-First_multiplier)+1;

vars First_product = First_multiplier ** 2;
vars Last_product = Last_multiplier ** 2;

vars prod_div = newarray([^First_product ^Last_product],
        procedure(x); []; endprocedure);

vars a b p product_list=[];

vars adding = false;

fast_for a from First_multiplier to Last_multiplier do
    fast_for b from First_multiplier to Last_multiplier do
        a*b -> p;
        unless p isin product_list then
            p :: product_list -> product_list;
        endunless;

        [^a ^b] :: prod_div(p) -> prod_div(p);

        if adding then
            a+b -> p;
            unless p isin product_list then
                p :: product_list -> product_list;
            endunless;
        endif;

    endfast_for;
endfast_for;

sort(product_list) -> product_list;

['?' ^^product_list] -> product_list;

vars problem_list = [% 'zero';
fast_for a from First_multiplier to Last_multiplier do
    fast_for b from First_multiplier to Last_multiplier do
        'p'><a><'x'><b;
    endfast_for;
endfast_for; %];

define code(n) -> string;
    vars i string = '';

    unless n isin product_list then
        mishap('PRODUCT_CODE: Product not in list of products',[^n]);
    endunless;

    fast_for i from 1 to length(product_list) do
        if product_list(i) = n then
            string >< '1 ' -> string;
        else
            string >< '0 ' -> string;
        endif;
    endfast_for;
enddefine;


define prodpr;
    vars i;
    fast_for i in product_list do
        pr_field(i,4,'.',false);
    endfast_for; nl(1);
enddefine;

prodpr();


vars tables_list = newarray([^First_multiplier ^Last_multiplier],
        procedure(a); vars j;
        [% for j from First_multiplier to Last_multiplier do
            a*j; endfor; %];
        endprocedure);


vars prob2prod = newarray([^First_multiplier ^Last_multiplier
                    ^First_multiplier ^Last_multiplier],
        procedure(x,y);
            vars pre;
            product_list --> [??pre ^(x*y) ==];
            length(pre)+1;
        endprocedure);

vars N_problems = length(problem_list);
vars N_products = length(product_list);
