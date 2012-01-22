/* Interface to C code to calculate upper percentge points of Student's
    t distribution */

vectorclass  float  decimal;

external_load('beta procedure for upper t',
    [%'/rsuna/home2/richardd/bin/sun4/beta.o',''%],
    [ {type procedure} [_upper_t C_upper_t] ]);

define upper_t(t,v) -> result;
    C_upper_t(t*1.0,intof(v),2,"decimal") -> result;
enddefine;
