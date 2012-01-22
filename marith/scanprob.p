vars dev = fopen('PROB.pat',"r");
fgetstring(dev) ->;
[% repeat 64 times
stringtolist(fgetstring(dev))(2);
endrepeat; %] -> list;
fclose(dev);

for a from 2 to 9 do
    for b from 2 to 9 do
        (a-2)*8+b-1 -> p;
        prnum(list(p)*100,2,0);pr(' ');
    endfor;
nl(1);
endfor;
