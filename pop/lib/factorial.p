
define factorial(n);
    lvars n;
    if n = 1 then
        1;
    else
        n * factorial(n-1);
    endif;
enddefine;
