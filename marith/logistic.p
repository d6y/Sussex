define logistic(x);
    if x > 15.935773 then
        0.99999988;
    elseif x < -15.935773 then
        0.00000012;
    else
        1.0/(1.0+exp(-x));
    endif;
enddefine;
