define listtostring(l,s) -> string;
    vars i,le=length(l);
    '' -> string;
    fast_for i from 1 to le do
        string><l(i) -> string;
        unless i=le then
            string><s -> string;
        endunless;
    endfast_for;
enddefine;
