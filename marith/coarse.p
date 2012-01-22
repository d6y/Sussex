
define encode(n,l) -> string;
vars i,d,s;
'' -> string;
0.85 -> s;
for i from First_multiplier to Last_multiplier do
    abs(i-n) ->d;
    string >< exp(-0.5*(d/s)**2) >< ' ' -> string;
endfor;
enddefine;

/*
for i from 0 to 12 do
pr(''><i><' '><encode(i,13)); nl(1);
endfor;
*/
