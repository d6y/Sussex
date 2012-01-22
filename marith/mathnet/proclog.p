
uses sysio;
uses statlib;
vars dev = fopen('log12',"r");

vars ne, tss, eq_tss = [], eq_epochs = [],
    sk_tss = [], sk_epochs = [];

repeat 10 times

    fgetstring(dev) ->;
    stringtolist(fgetstring(dev)) --> [?ne ?tss];
    tss :: sk_tss -> sk_tss;
    ne :: sk_epochs -> sk_epochs;
    fgetstring(dev) ->;
    stringtolist(fgetstring(dev)) --> [?ne ?tss];
    tss :: eq_tss -> eq_tss;
    ne :: eq_epochs -> eq_epochs;
    fgetstring(dev) ->;

endrepeat;

fclose(dev);

pr('Skew: Mean tss = '><
    mean(sk_tss)
    >< ' in '><
    mean(sk_epochs) >< ' epochs\n');

pr('Equalized: Mean tss = '><
    mean(eq_tss) >< ' in '><
    mean(eq_epochs) >< ' epochs\n');
