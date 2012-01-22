
uses statlib
uses sysio

vars file = 'dev';
vars points = [1 5 10 20 30 40 50 60 70 80 90 100];
vars runs = [a b c d e];
vars plt_files = ['omit' 'ode' 'oe' 'err'];

vars out = fopen(file><'.plot',"wc");

;;; Read epochs


vars dev, point_to_epoch, p;
[% for run in runs do
    fopen(file><run><'.log',"r") -> dev;
    [% for p in points do
        stringtolist(fgetstring(dev))(1);
    endfor; %];
fclose(dev);
endfor;%] -> data;

[% for p from 1 to length(points) do
        mean([% for r from 1 to length(runs) do
                    data(r)(p); endfor; %]);
    endfor; %] -> point_to_epoch;

;;; Read each plt file
vars f,x,y;


for f in plt_files do
    [% for run in runs do
    fopen(f><'-'><run><'.plt',"r") -> dev;
    fgetstring(dev) -> title;

    [% for p from 1 to length(points) do
        stringtolist(fgetstring(dev)) --> [?x ?y];
        y;
    endfor; %];
    fclose(dev);
    endfor; %] -> data;

    fputstring(out,title);

    for p from 1 to length(points) do

    fputstring(out,(point_to_epoch(p))><' '><
        mean([% for run from 1 to length(runs) do
            data(run)(p);
        endfor;
    %]));

    endfor;

    fnewline(out);
endfor;

fclose(out);
