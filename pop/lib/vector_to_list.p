define vector_to_list(v) -> l;
    lvars i, l=length(v);
    [% fast_for i from 1 to l do
            v(i);
        endfast_for; %] -> l;
enddefine;
