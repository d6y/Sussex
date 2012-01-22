
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

vars dev, N=15, nv = 10;

define poss_sd(n);
vars x;
n matches [ ^(consword('%'))
?x:isnumber] or n matches [?x:isnumber];
enddefine;

vars data = newarray([1 ^N 1 ^nv],0);

fopen('Proc.dev',"r") -> dev;

for n from 1 to N do

until stringtolist(fgetstring(dev)) matches
    [= tss ?v =] do enduntil;
v -> data(n,1);

stringtolist(fgetstring(dev)) --> [= performance ?v ==];
perf -> data(n,2);


stringtolist(fgetstring(dev)) --> [Number of errors ?v =];
v-> data(n,3);

for j from 4 to nv do

if j = 9 then
    data(n,8) + data(n,7) -> data(n,9);
else
    stringtolist(fgetstring(dev)) --> [== ?v:isnumber = =];
    v -> data(n,j);
endif;
endfor;
endfor;
fclose(dev);

[writing files]=>


fopen('gdat-tr',"w") -> dev;
fputstring(dev,'"Table related"');
for j from 1 to N do
fputstring(dev,j><' '><(data(j,5)));
endfor;
fclose(dev);

fopen('gdat-tu',"w") -> dev;
fputstring(dev,'"Table unrelated"');
for j from 1 to N do
fputstring(dev,j><' '><(data(j,9)));
endfor;
fclose(dev);
