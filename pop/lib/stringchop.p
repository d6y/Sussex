
/*

    Returns every Nth character from the STRING.

*/

define stringchop(string, n) -> short_string;
    lvars i, ls = length(string), short_string = '';
    fast_for i from 1 by n to ls do
        short_string >< substring(i,1,string) -> short_string;
    endfast_for;
enddefine;
