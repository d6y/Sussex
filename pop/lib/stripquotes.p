define stripquotes(string) -> newstring;
    vars c,i,newstring = '';
    fast_for i from 1 to length(string) do
        substring(i,1,string) -> c;
        unless c = '"' then
            newstring >< c -> newstring;
        endunless;
    endfast_for;
enddefine;
