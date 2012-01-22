
define encode(n);
vars i,d,s;
0.85 -> s;
for i from First_multiplier to Last_multiplier do
    abs(i-n) ->d;
    prnum(exp(-0.5*(d/s)**2),3,6); pr(' ');
endfor;
enddefine;

for i from 2 to 9 do
pr(i><': '); encode(i); nl(1);
endfor;
