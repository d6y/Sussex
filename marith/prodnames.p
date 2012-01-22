
vars dev = fopen('table.nms',"w");
vars a,b;
fputstring(dev,'zero');
fast_for a from 2 to 9 do
    fast_for b from 2 to 9 do
;;;        a*b - (intof(a*b/10)*10) -> p;
;;;if a==b then '*' -> p; else '-' -> p; endif;
a->p;
fputstring(dev,''><p);
    endfast_for;
endfast_for;

fclose(dev);
