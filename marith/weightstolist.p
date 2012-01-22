uses sysio;

define weightstolist(filename); /* -> list */
vars dev,line;
unless issubstring('.',filename) then filename><'.wts' -> filename; endunless;
fopen(filename,"r") -> dev;
[% repeat
    fgetstring(dev) -> line;
    quitif(line=termin);
    strnumber(line);
    endrepeat; %];
fclose(dev);
enddefine;
