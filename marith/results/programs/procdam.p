vars V = [
'Total sum squared error'
'Performance'
'Number of errors'
'Operand distance effect'
'Operand errors'
'High frequency products'
'Table unrelated (close)'
'Table unrelated (distant)'
'Table unrelated (all)'
'Operation errors'
];

vars dev, N=25, nv = 10;

define poss_sd(n);
vars x;
n matches [ ^(consword('%'))
?x:isnumber] or n matches [?x:isnumber];
enddefine;

vars data = newarray([1 ^N 1 ^nv],0);

fopen('damage.out',"r") -> dev;

for n from 1 to N do

until stringtolist(fgetstring(dev)) matches
    [== tss = ?v:isnumber ?perf:isnumber ==] do enduntil;
v -> data(n,1);
perf -> data(n,2);


until stringtolist(fgetstring(dev)) matches
    [Total of ?v errors ==] do enduntil;
v-> data(n,3);

for j from 4 to nv do

if j = 9 then
    data(n,8) + data(n,7) -> data(n,9);
else
    stringtolist(fgetstring(dev)) --> [== ?v:isnumber =];
    v -> data(n,j);
endif;
endfor;
endfor;
fclose(dev);

[writing files]=>

vars percentlist = [% for j from 0.1 by 0.2 to 5.0 do j; endfor;%];

for i from 1 to nv do
fopen('gdat'><i,"w") -> dev;
fputstring(dev,'"'><V(i)><'"');
for j from 1 to 25 do

fputstring(dev,percentlist(j)><' '><data(j,i));
endfor;
fclose(dev);
endfor;


rc_graphplot(1,1,N,'Epochs',data,'ODE%')-> region;
/*
rc_graphplot(1,1,7,'Age',[46 43.1 47.7 56.2 47.6 68.5 79.1],'TR%') -> region;
rc_print_at(2,85,'C&G per cent table related over age');

*/
