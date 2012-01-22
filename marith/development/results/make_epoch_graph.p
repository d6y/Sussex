
uses sysio

vars file = 'dev0_25';
vars points = [1 5 10 20 30 40 50 60 70 80 90 100];
vars plt_files = ['omit' 'ode' 'oe' 'err'];

vars out = fopen(file><'.plot',"wc");

;;; Read epochs

vars dev = fopen(file><'.log',"r"), point_to_epoch, p;
[% for p in points do
    stringtolist(fgetstring(dev))(1);
    endfor; %] -> point_to_epoch;
fclose(dev);

;;; Read each plt file
vars f,x,y;

for f in plt_files do
    fopen(f><'.plt',"r") -> dev;
    fputstring(out,fgetstring(dev));    ;;; copy title string
    for p from 1 to length(points) do
        stringtolist(fgetstring(dev)) --> [?x ?y];
        fputstring(out,point_to_epoch(p)><'  '><y);
    endfor;
    fnewline(out);
    fclose(dev);
endfor;

fclose(out);
