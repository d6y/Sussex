
raw_read_rt('c&gA85.rt') -> (tables,data);
flatten(data) -> data;

data =>

vars p;

define insert(x,y);
    vars p;
    1+(8*(x-2))+(y-2) -> p;
    [% x><'x'><y; data(p); %];
enddefine;

[% for a from 2 to 9 do
   sort_by_n_num([% for b from 2 to 9 do
        insert(a,b);
        insert(b,a);
    endfor; %],2) ==>
endfor; %] -> data;
